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
        "[#{format_repository repository_name}] #{format_user sender_name} " \
        'created fork ' \
        "#{format_user fork_owner_login}/#{format_repository fork_name}"
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
