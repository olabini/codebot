# frozen_string_literal: true

require 'codebot/message'
require 'codebot/payload'

module Codebot
  # A request which was received by the web server and can be delivered to the
  # IRC client.
  class Request
    # @return [Integration] the integration to deliver this request to
    attr_reader :integration

    # @return [Symbol] the event that triggered the webhook delivery
    attr_reader :event

    # @return [Payload] the parsed request payload
    attr_reader :payload

    # Constructs a new request for delivery to the IRC client.
    #
    # @param integration [Integration] the integration for which the request
    #                                  was made
    # @param event [Symbol] the event that triggered the webhook delivery
    # @param payload [String] a JSON string containing the request payload
    def initialize(integration, event, payload)
      @integration = integration
      @event       = event
      @payload     = Payload.new payload
    end

    # Invokes the given block for each network this request needs to be
    # delivered to.
    #
    # @yieldparam [Network] the network
    # @yieldparam [Array<Channels>] channels that belong to the network and
    #                               that a notification should be delivered to
    def each_network
      integration.channels.group_by(&:network).each do |network, channels|
        yield network, channels
      end
    end

    # Creates a message for a given channel from this request.
    #
    # @param channel [Channel] the channel
    # @return [Message] the created message
    def to_message_for(channel)
      Message.new(channel, @event, @payload)
    end
  end
end
