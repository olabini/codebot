# frozen_string_literal: true

module Codebot
  module Formatters
    # This module provides a formatter for ping events.
    module Ping
      extend Formatters

      # Formats an IRC message for a ping event.
      #
      # @param payload [Object] the JSON payload object
      # @return [String] the formatted message
      def self.format(payload)
        zen = extract payload, :zen
        "#{format_scope payload} Received ping: #{zen.inspect}"
      end

      # Formats the name of the repository or organization the webhook belongs
      # to.
      #
      # @param payload [Object] the JSON payload object
      # @return [String] the formatted scope
      def self.format_scope(payload)
        scope = case extract(payload, :hook, :type)
                when /\Aorganization\z/i
                  extract(payload, :organization, :login)
                when /\Arepository\z/i
                  extract(payload, :repository, :name)
                end
        format_repository(scope)
      end
    end
  end
end
