# frozen_string_literal: true

require 'thor'

require 'codebot/options/network'
require 'codebot/options/integration'

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
      class_option :quiet,
                   type: :boolean,
                   default: false,
                   aliases: '-q',
                   desc: 'Hide status information'

      desc 'network [OPTIONS]', 'Manage IRC networks'
      subcommand 'network', Network

      desc 'integration [OPTIONS]', 'Manage integrations'
      subcommand 'integration', Integration

      # Ensure that thor uses the correct exit code.
      #
      # @return true
      def self.exit_on_failure?
        true
      end
    end
  end
end
