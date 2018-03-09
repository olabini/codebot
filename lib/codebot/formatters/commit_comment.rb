# frozen_string_literal: true

# Portions (c) 2008 Logical Awesome, LLC (released under the MIT license).
# See the LICENSE file for the full MIT license text.

module Codebot
  module Formatters
    # This class formats commit_comment events.
    class CommitComment < Formatter
      # Formats IRC messages for a commit_comment event.
      #
      # @return [Array<String>] the formatted messages
      def format
        ["#{summary}: #{format_url url}"]
      end

      def summary
        short = abbreviate comment_body
        "[#{format_repository repository_name}] #{format_user sender_name} " \
        "commented on commit #{format_hash commit_id}: #{short}"
      end

      def summary_url
        extract(:comment, :html_url).to_s
      end

      def comment_body
        extract(:comment, :body).to_s
      end

      def commit_id
        extract(:comment, :commit_id)
      end
    end
  end
end
