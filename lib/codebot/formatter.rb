# frozen_string_literal: true

module Codebot
  # This class formats events.
  class Formatter
    # @return [Object] the JSON payload object
    attr_reader :payload

    # Initializes a new formatter.
    #
    # @param payload [Object] the JSON payload object
    def initialize(payload)
      @payload = payload
    end

    # Formats IRC messages for an unknown event.
    #
    # @return [Array<String>] the formatted messages
    def format
      ['An unknown event occurred']
    end

    # Formats a repository name.
    #
    # @param repository [String] the name
    # @return [String] the formatted name
    def format_repository(repository)
      ::Cinch::Formatting.format(:pink, repository)
    end

    # Formats a user name.
    #
    # @param user [String] the name
    # @return [String] the formatted name
    def format_user(user)
      ::Cinch::Formatting.format(:silver, user)
    end

    # Safely extracts a value from a JSON object.
    #
    # @param path [Array<#to_s>] the path to traverse
    # @return [Object, nil] the extracted object or +nil+ if no object was
    #                       found at the given path
    def extract(*path)
      node = payload
      node if path.all? do |sub|
        break unless node.is_a? Hash
        node = node[sub.to_s]
      end
    end
  end
end
