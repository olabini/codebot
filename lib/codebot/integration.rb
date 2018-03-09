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
      set_channels params[:channels], params[:config]
    end

    # Adds the specified channels to this integration.
    #
    # @note This method is not thread-safe and should only be called from an
    #       active transaction.
    # @param channels [Hash] the channel data to add
    # @param conf [Hash] the previously deserialized configuration
    # @raise [CommandError] if one of the channel identifiers already exists
    def add_channels!(channels, conf)
      channels.each_key do |identifier|
        if @channels.any? { |chan| chan.identifier_eql?(identifier) }
          raise CommandError, "channel #{identifier.inspect} already exists"
        end
      end
      new_channels = Channel.deserialize_all(channels, conf)
      @channels.push(*new_channels)
    end

    # Deletes the specified channels from this integration.
    #
    # @note This method is not thread-safe and should only be called from an
    #       active transaction.
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

    # Checks whether payloads delivered to this integration must be verified.
    #
    # @return [Boolean] whether verification is required
    def verify_payloads?
      !secret.to_s.strip.empty?
    end

    # Sets the list of channels.
    #
    # @param channels [Array<Channel>] the list of channels
    # @param conf [Hash] the previously deserialized configuration
    def set_channels(channels, conf)
      if channels.nil?
        @channels = [] if @channels.nil?
        return
      end
      @channels = valid!(channels, Channel.deserialize_all(channels, conf),
                         :@channels,
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

    # Serializes this integration.
    #
    # @param conf [Hash] the deserialized configuration
    # @return [Array, Hash] the serialized object
    def serialize(conf)
      check_channel_networks!(conf)
      [name, {
        'endpoint' => endpoint,
        'secret'   => secret,
        'channels' => Channel.serialize_all(channels, conf)
      }]
    end

    # Compares the channels against the specified configuration, dropping any
    # channels belonging to networks that no longer exist.
    #
    # @param conf [Config] the configuration
    def check_channel_networks!(conf)
      @channels.select! do |channel|
        conf[:networks].include? channel.network
      end
    end

    # Deserializes an integration.
    #
    # @param name [String] the name of the integration
    # @param data [Hash] the serialized data
    # @return [Hash] the parameters to pass to the initializer
    def self.deserialize(name, data)
      {
        name:     name,
        endpoint: data['endpoint'],
        secret:   data['secret'],
        channels: data['channels']
      }
    end

    # @return [true] to indicate that data is serialized into a hash
    def self.serialize_as_hash?
      true
    end
  end
end
