# frozen_string_literal: true

# Portions (c) 2008 Logical Awesome, LLC (released under the MIT license).
# See the LICENSE file for the full MIT license text.

module Codebot
  module Formatters
    # This class formats pull_request events.
    class PullRequest < Formatter
      # Formats IRC messages for a pull_request event.
      #
      # @return [Array<String>] the formatted messages
      def format
        ["#{summary}: #{format_url url}"] if opened? || closed?
      end

      def summary
        default_format.format(
          repository: format_repository(repository_name),
          sender: format_user(sender_name),
          action: action,
          number: pull_number,
          title: pull_title,
          base_ref: pull_base_ref,
          head_title: pull_head_title
        )
      end

      def default_format
        '[%<repository>] %<sender> %<action> pull request #%<number>: ' \
        '%<title> (%<base_ref>...%<head_title>)'
      end

      def pull_number
        extract(:pull_request, :number)
      end

      def pull_title
        extract(:pull_request, :title)
      end

      def pull_base_label
        extract(:pull_request, :base, :label)
      end

      def pull_base_ref
        pull_base_label.to_s.split(':').last
      end

      def pull_head_label
        extract(:pull_request, :head, :label)
      end

      def pull_head_ref
        pull_head_label.to_s.split(':').last
      end

      def pull_head_title
        if pull_head_ref == pull_base_ref
          pull_head_ref
        else
          pull_head_label
        end
      end

      def summary_url
        extract(:pull_request, :html_url).to_s
      end
    end
  end
end
