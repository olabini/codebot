# frozen_string_literal: true

require 'codebot/channel'
require 'codebot/cryptography'
require 'codebot/sanitizers'
require 'codebot/serializable'

module Codebot
  # This class represents an integration that maps an endpoint to the
  # corresponding IRC channels.
  class Integration < Serializable
    include Sanitizers

    # @return [String] the name of this integration
    attr_reader :name

    # @return [String] the endpoint mapped to this integration
    attr_reader :endpoint

    # @return [String] the secret for verifying the authenticity of payloads
    #                  delivered to the endpoint
    attr_reader :secret

    # @return [Array<Channel>] the channels notifications will be delivered to
    attr_reader :channels

    # Creates a new integration from the supplied hash.
    #
    # @param params [Hash] A hash with symbolic keys representing the instance
    #                      attributes of this integration. The key +:name+ is
    #                      required.
    def initialize(params)
      update!(params)
    end

    # Updates the integration from the supplied hash.
    #
    # @param params [Hash] A hash with symbolic keys representing the instance
    #                      attributes of this integration.
    def update!(params)
      self.name     = params[:name]
      self.endpoint = params[:endpoint]
      self.secret   = params[:secret]
      self.channels = params[:channels]
    end

    # Adds the specified channels to this integration. This method is not
    # thread-safe and should not be called outside a transaction.
    #
    # @param channels [Hash] the channel data to add
    # @raise [CommandError] if one of the channel identifiers already exists
    def add_channels!(channels)
      channels.each_key do |identifier|
        if @channels.any? { |chan| chan.identifier_eql?(identifier) }
          raise CommandError, "channel #{identifier.inspect} already exists"
        end
      end
      new_channels = Channel.load_all!(channels)
      @channels.push(*new_channels)
    end

    # Deletes the specified channels from this integration. This method is not
    # thread-safe and should not be called outside a transaction.
    #
    # @param identifiers [Array<String>] the channel identifiers to remove
    # @raise [CommandError] if one of the channel identifiers does not exist
    def delete_channels!(identifiers)
      identifiers.each do |identifier|
        channel = @channels.find { |chan| chan.identifier_eql? identifier }
        if channel.nil?
          raise CommandError, "channel #{identifier.inspect} does not exist"
        end
        @channels.delete channel
      end
    end

    def name=(name)
      @name = valid! name, valid_identifier(name), :@name,
                     required: true,
                     required_error: 'integrations must have a name',
                     invalid_error: 'invalid integration name %s'
    end

    def endpoint=(endpoint)
      @endpoint = valid!(endpoint, valid_endpoint(endpoint), :@endpoint,
                         invalid_error: 'invalid endpoint %s') do
        Cryptography.generate_endpoint
      end
    end

    def secret=(secret)
      @secret = valid!(secret, valid_secret(secret), :@secret,
                       invalid_error: 'invalid secret %s') do
        Cryptography.generate_secret
      end
    end

    def channels=(channels)
      @channels = valid!(channels, Channel.load_all!(channels), :@channels,
                         invalid_error: 'invalid channel list %s') { [] }
    end

    # Checks whether the name of this integration is equal to another name.
    #
    # @param name [String] the other name
    # @return [Boolean] +true+ if the names are equal, +false+ otherwise
    def name_eql?(name)
      @name.casecmp(name).zero?
    end

    # Checks whether the endpoint associated with this integration is equal
    # to another endpoint.
    #
    # @param endpoint [String] the other endpoint
    # @return [Boolean] +true+ if the endpoints are equal, +false+ otherwise
    def endpoint_eql?(endpoint)
      @endpoint.eql? endpoint
    end

    private_class_method def self.serial_key
      :name
    end

    private_class_method def self.serial_values
      %i[endpoint secret channels]
    end

    private_class_method def self.serial_value_types
      { channels: Channel }
    end
  end
end
