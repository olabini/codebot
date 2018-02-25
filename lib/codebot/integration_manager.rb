# frozen_string_literal: true

require 'codebot/network_manager'
require 'codebot/command_error'

module Codebot
  # This class manages the integrations associated with a configuration.
  class IntegrationManager
    # @return [Config] the configuration managed by this class
    attr_reader :config

    # Constructs a new integration manager for a specified configuration.
    #
    # @param config [Config] the configuration to manage
    def initialize(config)
      @config = config
    end

    # Creates a new integration from the given parameters.
    #
    # @param params [Hash] the parameters to initialize the integration with
    def create(params)
      integration = Integration.new(params)
      @config.transaction do
        check_available!(integration.name, integration.endpoint)
        NetworkManager.new(@config).check_channels!(integration)
        @config.integrations << integration
      end
    end

    # Updates an integration with the given parameters.
    #
    # @param name [String] the current name of the integration to update
    # @param params [Hash] the parameters to update the integration with
    def update(name, params)
      @config.transaction do
        integration = find_integration!(name)
        check_available_except!(params[:name], params[:endpoint], integration)
        update_channels!(integration, params)
        NetworkManager.new(@config).check_channels!(integration)
        integration.update!(params)
      end
    end

    # Destroys an integration.
    #
    # @param name [String] the name of the integration to destroy
    def destroy(name)
      @config.transaction do
        integration = find_integration!(name)
        @config.integrations.delete integration
      end
    end

    # Finds an integration given its name.
    #
    # @param name [String] the name to search for
    # @return [Integration, nil] the integration, or +nil+ if none was found
    def find_integration(name)
      @config.integrations.find { |intg| intg.name_eql? name }
    end

    # Finds an integration given its endpoint.
    #
    # @param endpoint [String] the endpoint to search for
    # @return [Integration, nil] the integration, or +nil+ if none was found
    def find_integration_by_endpoint(endpoint)
      @config.integrations.find { |intg| intg.endpoint_eql? endpoint }
    end

    # Finds an integration given its name.
    #
    # @param name [String] the name to search for
    # @raise [CommandError] if no integration with the given name exists
    # @return [Integration] the integration
    def find_integration!(name)
      integration = find_integration(name)
      return integration unless integration.nil?
      raise CommandError, "an integration with the name #{name.inspect} " \
                          'does not exist'
    end

    # Updates all integrations to account for a network name change.
    #
    # @param network [Network] the network to rename
    # @param new_name [String] the new name of the network
    def rename_network!(network, new_name)
      @config.integrations.each do |integration|
        integration.channels.each do |channel|
          channel.network = new_name if network.name_eql? channel.network
        end
      end
    end

    private

    # Checks that the specified name is available for use.
    #
    # @param name [String] the name to check for
    # @raise [CommandError] if the name is already taken
    def check_name_available!(name)
      return unless find_integration(name)
      raise CommandError, "an integration with the name #{name.inspect} " \
                          'already exists'
    end

    # Checks that the specified endpoint is available for use.
    #
    # @param endpoint [String] the endpoint to check for
    # @raise [CommandError] if the endpoint is already taken
    def check_endpoint_available!(endpoint)
      return unless find_integration_by_endpoint(endpoint)
      raise CommandError, 'an integration with the endpoint ' \
                          "#{endpoint.inspect} already exists"
    end

    # Checks that the specified name and endpoint are available for use.
    #
    # @param name [String] the name to check for
    # @param endpoint [String] the endpoint to check for
    # @raise [CommandError] if name or endpoint are already taken
    def check_available!(name, endpoint)
      check_name_available!(name) unless name.nil?
      check_endpoint_available!(endpoint) unless endpoint.nil?
    end

    # Checks that the specified name and endpoint are available for use by the
    # specified integration.
    #
    # @param name [String] the name to check for
    # @param endpoint [String] the endpoint to check for
    # @param integration [Integration] the integration to ignore
    # @raise [CommandError] if name or endpoint are already taken
    def check_available_except!(name, endpoint, integration)
      unless name.nil? || integration.name_eql?(name)
        check_name_available!(name)
      end
      return if endpoint.nil? || integration.endpoint_eql?(endpoint)
      check_endpoint_available!(endpoint)
    end

    # Updates the channels associated with an integration from the specified
    # parameters.
    #
    # @param integration [Integration] the integration
    # @param params [Hash] the parameters to update the integration with. Valid
    #                      keys are +:clear_channels+ to clear the channel list
    #                      before proceeding, +:add_channels+ to add the given
    #                      channels, and +:delete_channels+ to delete the given
    #                      channels from the integration. All keys are optional.
    #                      The value of +:clear_channels+ should be a boolean.
    #                      The value of +:add_channels+ should be a hash of the
    #                      form +identifier => params+, and +:remove_channels+
    #                      should be an array of channel identifiers to remove.
    def update_channels!(integration, params)
      integration.channels.clear if params[:clear_channels]
      if params[:delete_channels]
        integration.delete_channels!(params[:delete_channels])
      end
      integration.add_channels!(params[:add_channels]) if params[:add_channels]
    end
  end
end
