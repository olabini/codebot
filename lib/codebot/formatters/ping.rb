# frozen_string_literal: true

module Codebot
  module Formatters
    # This class formats ping events.
    class Ping < Formatter
      # Formats IRC messages for a ping event.
      #
      # @return [Array<String>] the formatted messages
      def format
        ["#{format_scope} Received ping: #{extract :zen}"]
      end

      # Formats the name of the repository or organization the webhook belongs
      # to.
      #
      # @return [String] the formatted scope
      def format_scope
        scope = case extract(:hook, :type)
                when /\Aorganization\z/i
                  extract(:organization, :login)
                when /\Arepository\z/i
                  extract(:repository, :name)
                end
        "[#{format_repository(scope)}]"
      end
    end
  end
end
