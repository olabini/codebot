# frozen_string_literal: true

require 'codebot/payload'

module Codebot
  # A request which was received by the web server and can be delivered to the
  # IRC client.
  class Request
    # @return [Integration] the integration to deliver this request to
    attr_reader :integration

    # @return [Payload] the parsed request payload
    attr_reader :payload

    # Constructs a new request for delivery to the IRC client.
    #
    # @param integration [Integration] the integration for which the request
    #                                  was made
    # @param payload [String] a JSON string containing the request payload
    def initialize(integration, payload)
      @integration = integration
      @payload     = Payload.new payload
    end
  end
end
