# frozen_string_literal: true

require 'json'

module Codebot
  # A JSON request payload.
  class Payload
    # @return [Object] the JSON object parsed from the request payload
    attr_reader :json

    # Constructs a new payload.
    #
    # @param payload [String] the request payload
    def initialize(payload)
      @json = JSON.parse payload
    end

    # Returns the JSON payload.
    #
    # @return [Object] the JSON object
    def to_json
      @json
    end

    # Returns the JSON string corresponding to the payload.
    #
    # @return [String] the JSON string
    def to_s
      @json.to_s
    end
  end
end
