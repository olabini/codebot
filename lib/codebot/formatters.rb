# frozen_string_literal: true

require 'cinch'
require 'codebot/formatter'
require 'codebot/formatters/ping'

module Codebot
  # This module provides methods for formatting outgoing IRC messages.
  module Formatters
    # Formats an IRC message.
    #
    # @param event [Symbol] the webhook event
    # @param payload [Object] the JSON payload object
    # @param color [Boolean] whether to use formatting codes
    # @return [String] the formatted message
    def self.format(event, payload, color = true)
      message = "\x0F" + format_color(event, payload)
      if color
        message
      else
        ::Cinch::Formatting.unformat message
      end
    end

    # Formats a colored IRC message. This method should not be called directly
    # from outside this module.
    #
    # @param event [Symbol] the webhook event
    # @param payload [Object] the JSON payload object
    # @return [String] the formatted message
    def self.format_color(event, payload)
      case event
      when :ping then Formatters::Ping.new(payload).format
      else "Error: missing formatter for #{event.inspect}"
      end
    end
  end
end
