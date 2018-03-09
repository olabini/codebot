# frozen_string_literal: true

module Codebot
  module Formatters
    # This class formats watch events.
    class Watch < Formatter
      # Formats IRC messages for a watch event.
      #
      # @return [Array<String>] the formatted messages
      def format
        ["#{summary}: #{format_url url}"] if started?
      end

      def action
        extract(:action)
      end

      def started?
        action.eql? 'started'
      end

      def summary
        "[#{format_repository repository_name}] #{format_user sender_name} " \
        'starred the repository'
      end

      def summary_url
        "#{repository_url}/stargazers"
      end
    end
  end
end
