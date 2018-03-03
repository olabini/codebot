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
        check_not_running!(options)
        Options.with_core(options) do |core|
          core.trap_signals
          core.start
          core.join
        end
      end

      desc 'start', 'Start a new Codebot instance in the background'

      # Starts a new Codebot instance in the background.
      def start
        Options.with_errors do
          unless Process.respond_to?(:fork)
            raise CommandError, 'this feature is not available on ' \
                                "#{RUBY_PLATFORM}; please use the " \
                                "'interactive' command instead"
          end
        end
        check_not_running!(options)
        fork { interactive }
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
    end
  end
end
