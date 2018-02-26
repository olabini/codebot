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
  end
end
