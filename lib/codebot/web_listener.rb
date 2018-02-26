# frozen_string_literal: true

require 'codebot/integration_manager'
require 'codebot/request'

module Codebot
  # This module provides methods for processing incoming webhooks and
  # dispatching them to the IRC client.
  module WebListener
    # Handles a POST request.
    #
    # @param core [Core] the bot to dispatch requests to
    # @param request [Sinatra::Request] the request to handle
    # @param params [Hash] the request parameters
    def handle_post(core, request, params)
      payload = params['payload'] || request.body.read
      if dispatch(core, *params['splat'], payload)
        [202, 'Accepted']
      else
        [404, 'Endpoint Not Registered']
      end
    rescue JSON::ParserError
      [400, 'Bad Request']
    end

    # Dispatch a received payload to the IRC client.
    #
    # @param core [Core] the bot to dispatch this request to
    # @param endpoint [String] the endpoint at which the request was received
    # @param payload [String] the payload sent to the endpoint
    # @return [Boolean] whether the requested endpoint exists
    def dispatch(core, endpoint, payload)
      manager = IntegrationManager.new(core.config)
      integration = manager.find_integration_by_endpoint endpoint
      return false if integration.nil?
      core.irc_client.dispatch(Request.new(integration, payload))
      true
    end
  end
end
