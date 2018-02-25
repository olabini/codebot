# frozen_string_literal: true

require 'codebot/command_error'

module Codebot
  # This class manages the networks associated with a configuration.
  class NetworkManager
    # @return [Config] the configuration managed by this class
    attr_reader :config

    # Constructs a new network manager for a specified configuration.
    #
    # @param config [Config] the configuration to manage
    def initialize(config)
      @config = config
    end

    # Creates a new network from the given parameters.
    #
    # @param params [Hash] the parameters to initialize the network with
    def create(params)
      network = Network.new(params)
      @config.transaction do
        check_name_available!(network.name)
        @config.networks << network
      end
    end

    # Updates a network with the given parameters.
    #
    # @param name [String] the current name of the network to update
    # @param params [Hash] the parameters to update the network with
    def update(name, params)
      @config.transaction do
        network = find_network!(name)
        unless params[:name].nil?
          check_name_available_except!(params[:name], network)
          IntegrationManager.new(@config).rename_network!(network,
                                                          params[:name])
        end
        network.update!(params)
      end
    end

    # Destroys a network.
    #
    # @param name [String] the name of the network to destroy
    def destroy(name)
      @config.transaction do
        network = find_network!(name)
        @config.networks.delete network
      end
    end

    # Finds a network given its name.
    #
    # @param name [String] the name to search for
    # @return [Network, nil] the network, or +nil+ if none was found
    def find_network(name)
      @config.networks.find { |net| net.name_eql? name }
    end

    # Finds a network given its name.
    #
    # @param name [String] the name to search for
    # @raise [CommandError] if no network with the given name exists
    # @return [Network] the network
    def find_network!(name)
      network = find_network(name)
      return network unless network.nil?
      raise CommandError, "a network with the name #{name.inspect} " \
                          'does not exist'
    end

    # Checks that all channels associated with an integration belong to a valid
    # network.
    #
    # @param integration [Integration] the integration to check
    def check_channels!(integration)
      integration.channels.map(&:network).each do |network_name|
        find_network!(network_name)
      end
    end

    private

    # Checks that the specified name is available for use.
    #
    # @param name [String] the name to check for
    # @raise [CommandError] if the name is already taken
    def check_name_available!(name)
      return if name.nil? || !find_network(name)
      raise CommandError, "a network with the name #{name.inspect} " \
                          'already exists'
    end

    # Checks that the specified name is available for use by the specified
    # network.
    #
    # @param name [String] the name to check for
    # @param network [Network] the network to ignore
    # @raise [CommandError] if the name is already taken
    def check_name_available_except!(name, network)
      return if name.nil? || network.name_eql?(name) || !find_network(name)
      raise CommandError, "a network with the name #{name.inspect} " \
                          'already exists'
    end
  end
end
