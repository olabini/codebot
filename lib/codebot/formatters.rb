# frozen_string_literal: true

require 'codebot/formatters/ping'

module Codebot
  # This module provides methods for formatting outgoing IRC messages.
  module Formatters
    # Formats an IRC message.
    #
    # @param event [Symbol] the webhook event
    # @param payload [Object] the JSON payload object
    # @return [String] the formatted message
    def self.format(event, payload)
      case event
      when :ping then Formatters::Ping.format payload
      else "Error: missing formatter for #{event.inspect}"
      end
    end

    # Safely extracts a value from a JSON object.
    #
    # @param payload [Object] the payload object
    # @param path [Array<#to_s>] the path to traverse
    # @return [Object, nil] the extracted object or +nil+ if no object was
    #                       found at the given path
    def extract(payload, *path)
      node = payload
      node if path.all? do |sub|
        break unless node.is_a? Hash
        node = node[sub.to_s]
      end
    end
  end
end
