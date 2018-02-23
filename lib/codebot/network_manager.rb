# frozen_string_literal: true

require 'codebot/command_error'

module Codebot
  # This class manages the networks associated with a configuration.
  class NetworkManager
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
      @config.transaction do |conf|
        check_name_missing!(conf, network.name)
        conf.networks << network
      end
    end

    # Updates a network with the given parameters.
    #
    # @param name [String] the current name of the network to update
    # @param params [Hash] the parameters to update the network with
    def update(name, params)
      @config.transaction do |conf|
        network = find_network!(conf, name)
        unless network.name_eql? params[:name]
          check_name_missing!(conf, params[:name])
        end
        network.update!(params)
      end
    end

    # Destroys a network.
    #
    # @param name [String] the name of the network to destroy
    def destroy(name)
      @config.transaction do |conf|
        network = find_network!(conf, name)
        conf.networks.delete network
      end
    end

    private

    def find_network(conf, name)
      conf.networks.find { |net| net.name_eql? name }
    end

    def find_network!(conf, name)
      network = find_network(conf, name)
      return network unless network.nil?
      raise CommandError, "a network with the name #{name.inspect} " \
                          'does not exist'
    end

    def check_name_missing!(conf, name)
      return unless find_network(conf, name)
      raise CommandError, "a network with the name #{name.inspect} " \
                          'already exists'
    end
  end
end
