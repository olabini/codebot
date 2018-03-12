# frozen_string_literal: true

require 'codebot/ipc_client'

module Codebot
  module Options
    # A class that handles the +codebot core+ command.
    class Core < Thor
      check_unknown_options!

      desc 'interactive', 'Run Codebot interactively'

      # Runs Codebot interactively.
      def interactive
        run_core(true)
      end

      desc 'start', 'Start a new Codebot instance in the background'

      # Starts a new Codebot instance in the background.
      def start
        Options.with_errors { check_fork_supported! }
        check_not_running!(options)
        fork { run_core(false) }
      end

      desc 'stop', 'Stop a running Codebot instance'

      # Stops a running Codebot instance.
      def stop
        Options.with_ipc_client(options, &:send_stop)
      end

      desc 'rehash', 'Reload the configuration of a running Codebot instance'

      # Reloads the configuration of a running Codebot instance.
      def rehash
        Options.with_ipc_client(options, &:send_rehash)
      end

      # Ensures that thor uses the correct exit code.
      #
      # @return true
      def self.exit_on_failure?
        true
      end

      private

      # Ensures that a Codebot instance using the same pipe is not already
      # running.
      #
      # @param opts [Hash] a hash containing the options that would be used for
      #                    initializing a new core; specifically, a hash
      #                    containing the +:pipe+ key to indicate the path to
      #                    the named pipe used by the IPC server.
      # @raise [CommandError] if the named pipe already exists
      def check_not_running!(opts)
        Options.with_ipc_client(opts) do |ipc|
          break unless ipc.pipe_exist?
          raise CommandError, 'named pipe already exists; if you are sure a ' \
                              'Codebot instance is not already running, you ' \
                              "can delete #{ipc.pipe.inspect}"
        end
      end

      # Ensures that the current platform supports the Process::fork method,
      # raising an error if it does not.
      #
      # @raise [CommandError] if forking is not supported
      def check_fork_supported!
        return if Process.respond_to?(:fork)
        raise CommandError, 'this feature is not available on ' \
                            "#{RUBY_PLATFORM}; please use the " \
                            "'interactive' command instead"
      end

      # Reopens the standard file descriptors to prevent the forked process
      # from inheriting the file descriptors of the parent process. This method
      # reopens streams using a method similar to the Unix dup2 function.
      #
      # @param sin [File] the file to redirect into the standard input stream,
      #                    or +nil+ to detach and immediately close the stream.
      # @param sout [File] the file to redirect the standard output stream to,
      #                    or +nil+ to discard any data written to the stream.
      # @param serr [File] the file to redirect the standard error stream to,
      #                    or +nil+ to discard any data written to the stream.
      def dup2_fds(sin: nil, sout: nil, serr: nil)
        $stdin.reopen(sin || null_file('r'))
        $stdout.reopen(sout || null_file('w'))
        $stderr.reopen(serr || null_file('w'))
      end

      # Creates a new null file.
      #
      # @param mode [String] the mode to open the file in
      # @return [File] the created file
      def null_file(mode)
        File.new(File::NULL, mode)
      end

      # Initializes any missing environment variables to their default values.
      def initialize_environment
        ENV['CODEBOT_PORT'] ||= 4567.to_s
        ENV['RACK_ENV'] ||= 'production'
      end

      # Starts the bot. Unless started in interactive mode, file descriptors
      # are reopened from a null file.
      #
      # @param interactive [Boolean] whether to start the bot in the foreground
      def run_core(interactive)
        initialize_environment
        check_not_running!(options)
        dup2_fds unless interactive
        Options.with_core(options) do |core|
          core.trap_signals
          core.start
          core.join
        end
      end
    end
  end
end
