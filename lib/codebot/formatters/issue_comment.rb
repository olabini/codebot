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
        default_format % {
          repository: format_repository(repository_name),
          sender: format_user(sender_name),
          number: issue_number,
          summary: prettify(comment_body)
        }
      end

      def default_format
        '[%<repository>s] %<sender>s commented on issue #%<number>s: %<summary>s'
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
