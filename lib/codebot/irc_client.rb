# frozen_string_literal: true

require 'codebot/irc_connection'

module Codebot
  # This class manages an IRC client.
  class IRCClient
    # Creates a new IRC client.
    #
    # @param core [Core] the bot this client belongs to
    def initialize(core)
      @active = false
      @checkpoint = []
      @connections = []
      @core = core
      @semaphore = Mutex.new
    end

    # Dispatches a new request.
    #
    # @param request [Request] the request to dispatch
    def dispatch(request)
      @requests << request
    end

    # Starts this IRC client.
    def start
      @active = true
      migrate!
    end

    # Stops this IRC client.
    def stop
      @active = false
      @checkpoint.clear
      @connections.each(&:stop)
      @connections.each(&:join)
      @connections.clear
    end

    # Connects to and disconnects from networks as necessary in order for the
    # list of connections to reflect changes to the configuration.
    def migrate!
      @semaphore.synchronize do
        return unless @active
        networks = @core.config.networks
        (@checkpoint - networks).each { |network| disconnect_from network }
        (networks - @checkpoint).each { |network| connect_to      network }
        @checkpoint = networks
      end
    end

    private

    # Finds the connection to a given network.
    #
    # @param network [Network] the network
    # @return [IRCConnection, nil] the connection, or +nil+ if none was found
    def connection_for(network)
      @connections.find { |con| con.network.eql? network }
    end

    # Checks whether the client is connected to a given network.
    #
    # @param network [Network] the network
    # @return [Boolean] +true+ if the client is connected, +false+ otherwise
    def connected_to?(network)
      !connection_for(network).nil?
    end

    # Connects to a given network if the same network is not already connected.
    #
    # @param network [Network] the network to connect to
    def connect_to(network)
      return if connected_to? network
      @connections << IRCConnection.new(network).tap(&:start)
    end

    # Disconnects from a given network if the network is currently connected.
    #
    # @param network [Network] the network to disconnected from
    def disconnect_from(network)
      connection = @connections.delete connection_for(network)
      connection.tap(&:stop).tap(&:join) unless connection.nil?
    end
  end
end
