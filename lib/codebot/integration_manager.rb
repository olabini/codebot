# frozen_string_literal: true

require 'codebot/command_error'

module Codebot
  # This class manages the integrations associated with a configuration.
  class IntegrationManager
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
      @config.transaction do |conf|
        check_available!(conf, integration.name, integration.endpoint)
        conf.integrations << integration
      end
    end

    # Updates an integration with the given parameters.
    #
    # @param name [String] the current name of the integration to update
    # @param params [Hash] the parameters to update the integration with
    def update(name, params)
      @config.transaction do |conf|
        integration = find_integration!(conf, name)
        check_available!(conf, params[:name], params[:endpoint], integration)
        update_channels!(integration, params)
        integration.update!(params)
      end
    end

    # Destroys an integration.
    #
    # @param name [String] the name of the integration to destroy
    def destroy(name)
      @config.transaction do |conf|
        integration = find_integration!(conf, name)
        conf.integrations.delete integration
      end
    end

    private

    def find_integration(conf, name)
      conf.integrations.find { |intg| intg.name_eql? name }
    end

    def find_integration_by_endpoint(conf, endpoint)
      conf.integrations.find { |intg| intg.endpoint_eql? endpoint }
    end

    def find_integration!(conf, name)
      integration = find_integration(conf, name)
      return integration unless integration.nil?
      raise CommandError, "an integration with the name #{name.inspect} " \
                          'does not exist'
    end

    def check_name_available!(conf, name)
      return unless find_integration(conf, name)
      raise CommandError, "an integration with the name #{name.inspect} " \
                          'already exists'
    end

    def check_endpoint_available!(conf, endpoint)
      return unless find_integration_by_endpoint(conf, endpoint)
      raise CommandError, 'an integration with the endpoint ' \
                          "#{endpoint.inspect} already exists"
    end

    def check_available!(conf, name, endpoint, integration = nil)
      unless name.nil? || (!integration.nil? && integration.name_eql?(name))
        check_name_available!(conf, name)
      end
      check_endpoint_available!(conf, endpoint) unless endpoint.nil?
    end

    def update_channels!(integration, params)
      integration.channels.clear if params[:clear_channels]
      if params[:delete_channels]
        integration.delete_channels!(params[:delete_channels])
      end
      integration.add_channels!(params[:add_channels]) if params[:add_channels]
    end
  end
end
