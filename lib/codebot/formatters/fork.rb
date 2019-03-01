# frozen_string_literal: true

module Codebot
  module Formatters
    # This class formats fork events.
    class Fork < Formatter
      # Formats IRC messages for a fork event.
      #
      # @return [Array<String>] the formatted messages
      def format
        ["#{summary}: #{format_url url}"]
      end

      def summary
        default_format.format(
          repository: format_repository(repository_name),
          sender: format_user(sender_name),
          fork_owner: format_user(fork_owner_login),
          fork_name: format_repository(fork_name)
        )
      end

      def default_format
        '[%<repository>s] %<sender>s created fork %<fork_owner>s/%<fork_name>s'
      end

      def fork_owner_login
        extract(:forkee, :owner, :login)
      end

      def fork_name
        extract(:forkee, :name)
      end

      def summary_url
        extract(:forkee, :html_url).to_s
      end
    end
  end
end
