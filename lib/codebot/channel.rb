# frozen_string_literal: true

require 'codebot/sanitizers'
require 'codebot/serializable'

module Codebot
  # This class represents an IRC channel notifications can be delivered to.
  class Channel < Serializable
    include Sanitizers

    # @return [String] the name of this channel
    attr_reader :name

    # @return [Network] the network this channel belongs to
    attr_reader :network

    # @return [String, nil] the key required for joining this channel
    attr_reader :key

    # @return [Boolean] whether to send messages without joining this channel
    attr_reader :send_external

    # Creates a new channel from the supplied hash.
    #
    # @param params [Hash] A hash with symbolic keys representing the instance
    #                      attributes of this channel. The keys +:name+ and
    #                      +:network+ are required. Alternatively, the key
    #                      +:identifier+, which should use the format
    #                      +network/name+, can be specified.
    def initialize(params)
      update!(params)
    end

    # Updates the channel from the supplied hash.
    #
    # @param params [Hash] A hash with symbolic keys representing the instance
    #                      attributes of this channel.
    def update!(params)
      set_identifier params[:identifier], params[:config] if params[:identifier]
      self.name          = params[:name]
      self.key           = params[:key]
      self.send_external = params[:send_external]
      set_network params[:network], params[:config]
    end

    def name=(name)
      @name = valid! name, valid_channel_key(name), :@name,
                     required: true,
                     required_error: 'channels must have a name',
                     invalid_error: 'invalid channel name %s'
    end

    # Sets the network for this channel.
    #
    # @param network [String] the name of the network
    # @param conf [Hash] the configuration containing all networks
    def set_network(network, conf)
      @network = valid! network, valid_network(network, conf), :@network,
                        required: true,
                        required_error: 'channels must have a network',
                        invalid_error: 'invalid channel network %s'
    end

    def key=(key)
      @key = valid! key, valid_channel_key(key), :@key,
                    invalid_error: 'invalid channel key %s'
    end

    def key?
      !key.to_s.strip.empty?
    end

    def send_external=(send_external)
      @send_external = valid!(send_external, valid_boolean(send_external),
                              :@send_external,
                              invalid_error: 'send_external must be a ' \
                                             'boolean') { false }
    end

    # Checks whether the identifier of this channel is equal to another
    # identifier.
    #
    # @param identifier [String] the other identifier
    # @return [Boolean] +true+ if the names are equal, +false+ otherwise
    def identifier_eql?(identifier)
      self.identifier.casecmp(identifier).zero?
    end

    # Returns the string used to identify this channel in configuration files.
    #
    # @return [String] the identifier
    def identifier
      "#{@network.name}/#{@name}"
    end

    # Sets network and channel name based on the given identifier.
    #
    # @param identifier [String] the identifier
    # @param conf [Hash] the configuration containing all networks
    def set_identifier(identifier, conf)
      network_name, self.name = identifier.split('/', 2) if identifier
      set_network(network_name, conf)
    end

    # Serializes this channel.
    #
    # @param _conf [Hash] the deserialized configuration
    # @return [Array, Hash] the serialized object
    def serialize(_conf)
      [identifier, {
        'key'           => key,
        'send_external' => send_external
      }]
    end

    # Deserializes a channel.
    #
    # @param identifier [String] the channel identifier
    # @param data [Hash] the serialized data
    # @return [Hash] the parameters to pass to the initializer
    def self.deserialize(identifier, data)
      {
        identifier:    identifier,
        key:           data['key'],
        send_external: data['send_external']
      }
    end

    # @return [true] to indicate that data is serialized into a hash
    def self.serialize_as_hash?
      true
    end
  end
end
