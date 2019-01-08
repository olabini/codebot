# frozen_string_literal: true

module Codebot
  module Formatters
    # This class formats public events.
    class Public < Formatter
      # Formats IRC messages for a public event.
      #
      # @return [Array<String>] the formatted messages
      def format
        ["#{summary}: #{format_url url}"]
      end

      def summary
        default_format % {
          repository: format_repository(repository_name),
          sender: format_user(sender_name)
        }
      end

      def default_format
        '[%<repository>s] %<sender>s open-sourced the repository'
      end

      def summary_url
        repository_url
      end
    end
  end
end
