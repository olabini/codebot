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
        default_format % {
          repository: format_repository(repository_name),
          sender: format_user(sender_name),
          hash: format_hash(commit_id),
          summary: prettify(comment_body)
        }
      end

      def default_format
        '[%{repository}] %{sender} commented on commit %{hash}: %{summary}'
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
