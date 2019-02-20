# frozen_string_literal: true

require 'codebot/cryptography'
require 'codebot/event'
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
      dispatch(core, request, *params['splat'], payload)
    rescue JSON::ParserError
      [400, 'Invalid JSON payload']
    end

    # Finds the integration associated with an endpoint.
    #
    # @param config [Config] the configuration containing the integrations
    # @param endpoint [String] the endpoint
    def integration_for(config, endpoint)
      IntegrationManager.new(config).find_integration_by_endpoint(endpoint)
    end

    # Dispatches a received payload to the IRC client.
    #
    # @param core [Core] the bot to dispatch this request to
    # @param request [Sinatra::Request] the request received by the web server
    # @param endpoint [String] the endpoint at which the request was received
    # @param payload [String] the payload that was sent to the endpoint
    # @return [Array<Integer, String>] HTTP status code and response
    def dispatch(core, request, endpoint, payload)
      intg = integration_for(core.config, endpoint)
      return [404, 'Endpoint not registered'] if intg.nil?
      return [403, 'Invalid signature'] unless valid?(request, intg, payload)
      req = create_request(intg, request, payload)
      return req if req.is_a? Array
      core.irc_client.dispatch(req)
      [202, 'Accepted']
    end

    # Creates a new request for the webhook.
    #
    # @param integration [Integration] the integration for which the request
    #                                  was made
    # @param request [Sinatra::Request] the request received by the web server
    # @param payload [String] the payload that was sent to the endpoint
    # @return [Request, Array<Integer, String>] the created request, or an
    #                                           array containing HTTP status
    #                                           code and response if the
    #                                           request was invalid
    def create_request(integration, request, payload)
      if integration.gitlab
        event = request.env['HTTP_X_GITLAB_EVENT']
        return [400, 'Missing event header'] if event.nil? || event.empty?
        event = Event.symbolize("Gitlab #{event}".gsub(/ /, '_')
        return [501, 'Event not yet supported'] if event.nil?
        Request.new(integration, event, payload) unless event.nil?
      else
        event = request.env['HTTP_X_GITHUB_EVENT']
        return [400, 'Missing event header'] if event.nil? || event.empty?
        event = Event.symbolize(event)
        return [501, 'Event not yet supported'] if event.nil?
        Request.new(integration, event, payload) unless event.nil?
      end
    end

    # Verifies a webhook signature.
    #
    # @param request [Sinatra::Request] the request received by the web server
    # @param integration [Integration] the integration for which the request
    #                                  was made
    # @param payload [String] the payload that was sent to the endpoint
    # @return [Boolean] whether the signature is valid
    def valid?(request, integration, payload)
      return true unless integration.verify_payloads?
      secret = integration.secret
      if integration.gitlab
        secret == request.env['HTTP_X_GITLAB_TOKEN']
      else 
        request_signature = request.env['HTTP_X_HUB_SIGNATURE']
        Cryptography.valid_signature?(payload, secret, request_signature)
      end
    end
  end
end
