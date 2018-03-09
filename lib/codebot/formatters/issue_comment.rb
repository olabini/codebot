# frozen_string_literal: true

module Codebot
  module Formatters
    # This class formats issue_comment events.
    class IssueComment < Formatter
      # Formats IRC messages for an issue_comment event.
      #
      # @return [Array<String>] the formatted messages
      def format
        ["#{summary}: #{format_url url}"]
      end

      def summary
        short = abbreviate comment_body
        "[#{format_repository repository_name}] #{format_user sender_name} " \
        "commented on issue \##{issue_number}: #{short}"
      end

      def summary_url
        extract(:comment, :html_url).to_s
      end

      def comment_body
        extract(:comment, :body).to_s
      end

      def issue_number
        extract(:issue, :number)
      end
    end
  end
end
