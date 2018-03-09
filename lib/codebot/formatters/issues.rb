# frozen_string_literal: true

module Codebot
  module Formatters
    # This class formats issues events.
    class Issues < Formatter
      # Formats IRC messages for an issue event.
      #
      # @return [Array<String>] the formatted messages
      def format
        ["#{summary}: #{format_url url}"] if opened? || closed?
      end

      def summary
        "[#{format_repository repository_name}] #{format_user sender_name} " \
        "#{action} issue \##{issue_number}: #{issue_title}"
      end

      def summary_url
        extract(:issue, :html_url).to_s
      end

      def issue_number
        extract(:issue, :number)
      end

      def issue_title
        extract(:issue, :title)
      end
    end
  end
end
