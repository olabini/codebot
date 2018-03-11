# frozen_string_literal: true

require 'thor'

require 'codebot/options/core'
require 'codebot/options/network'
require 'codebot/options/integration'
require 'codebot/user_error'

module Codebot
  module Options
    # A class that handles the +codebot+ command. This class delegates handling
    # of any commands to the respective class for the appropriate subcommand.
    class Base < Thor
      check_unknown_options!

      class_option :config,
                   banner: 'FILE',
                   aliases: '-C',
                   desc: 'Use the specified alternate configuration file'
      class_option :pipe,
                   banner: 'FILE',
                   aliases: '-P',
                   desc: 'Use the specified alternate named pipe'
      class_option :quiet,
                   type: :boolean,
                   default: false,
                   aliases: '-q',
                   desc: 'Hide status information'

      desc 'core [OPTIONS]', 'Manage a Codebot core'
      subcommand 'core', Core

      desc 'network [OPTIONS]', 'Manage IRC networks'
      subcommand 'network', Network

      desc 'integration [OPTIONS]', 'Manage integrations'
      subcommand 'integration', Integration

      # Ensures that thor uses the correct exit code.
      #
      # @return true
      def self.exit_on_failure?
        true
      end

      if Process.uid.zero? || Process.euid.zero?
        STDERR.puts 'Running Codebot as root is extremely dangerous; ' \
                    "if you're trying to listen on a privileged port " \
                    'please use a gateway server instead'
        exit 1
      end
    end
  end
end
