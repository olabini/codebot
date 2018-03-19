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
        default_format.format(
          repository: format_repository(repository_name),
          sender: format_user(sender_name),
          action: action,
          number: issue_number,
          title: issue_title
        )
      end

      def default_format
        '[%{repository}] %{sender} %{action} issue #%{number}: %{title}'
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
