# frozen_string_literal: true

require 'cinch'
require 'codebot/formatter'
require 'codebot/formatters/ping'
require 'codebot/formatters/push'

module Codebot
  # This module provides methods for formatting outgoing IRC messages.
  module Formatters
    # Formats IRC messages for an event.
    #
    # @param event [Symbol] the webhook event
    # @param payload [Object] the JSON payload object
    # @param color [Boolean] whether to use formatting codes
    # @return [Array<String>] the formatted messages
    def self.format(event, payload, color = true)
      messages = format_color(event, payload)
      messages.map! { |msg| "\x0F" + msg }
      messages.map! { |msg| ::Cinch::Formatting.unformat(msg) } unless color
      messages
    rescue StandardError => e
      STDERR.puts e.message
      STDERR.puts e.backtrace
      url = ::Cinch::Formatting.format(:blue, :underline, FORMATTER_ISSUE_URL)
      ['An error occurred while formatting this message. More information ' \
       "has been printed to STDERR. Please report this issue to #{url}."]
    end

    # Formats colored IRC messages. This method should not be called directly
    # from outside this module.
    #
    # @param event [Symbol] the webhook event
    # @param payload [Object] the JSON payload object
    # @return [Array<String>] the formatted messages
    def self.format_color(event, payload)
      case event
      when :ping then Formatters::Ping.new(payload).format
      when :push then Formatters::Push.new(payload).format
      else "Error: missing formatter for #{event.inspect}"
      end
    end
  end
end
