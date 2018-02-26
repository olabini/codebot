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

      def check_not_running!(opts)
        Options.with_ipc_client(opts) do |ipc|
          return unless ipc.pipe_exist?
          raise CommandError, "named pipe #{ipc.pipe.inspect} already " \
                              "exists; is there already a running instance?"
        end
      end
    end
  end
end
