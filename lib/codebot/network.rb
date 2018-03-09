# frozen_string_literal: true

require 'codebot/sanitizers'
require 'codebot/serializable'

module Codebot
  # This class represents an IRC network notifications can be delivered to.
  class Network < Serializable
    include Sanitizers

    # @return [String] the name of this network
    attr_reader :name

    # @return [String] the hostname or IP address used for connecting to this
    #                  network
    attr_reader :host

    # @return [Integer] the port used for connecting to this network
    attr_reader :port

    # @return [Boolean] whether TLS should be used when connecting to this
    #                   network
    attr_reader :secure

    # @return [String] the server password
    attr_reader :server_password

    # @return [String] the primary nickname for this network
    attr_reader :nick

    # @return [String] the username for SASL authentication
    attr_reader :sasl_username

    # @return [String] the password for SASL authentication
    attr_reader :sasl_password

    # @return [String] the address to bind to
    attr_reader :bind

    # @return [String] user modes to set
    attr_reader :modes

    # Creates a new network from the supplied hash.
    #
    # @param params [Hash] A hash with symbolic keys representing the instance
    #                      attributes of this network. The keys +:name+ and
    #                      +:host+ are required.
    def initialize(params)
      update!(params)
    end

    # Updates the network from the supplied hash.
    #
    # @param params [Hash] A hash with symbolic keys representing the instance
    #                      attributes of this network.
    def update!(params)
      self.name            = params[:name]
      self.server_password = params[:server_password]
      self.nick            = params[:nick]
      self.bind            = params[:bind]
      self.modes           = params[:modes]
      update_connection(params[:host], params[:port], params[:secure])
      update_sasl(params[:disable_sasl],
                  params[:sasl_username], params[:sasl_password])
    end

    def name=(name)
      @name = valid! name, valid_identifier(name), :@name,
                     required: true,
                     required_error: 'networks must have a name',
                     invalid_error: 'invalid network name %s'
    end

    # Updates the connection details of this network.
    #
    # @param host [String] the new hostname, or +nil+ to keep the current value
    # @param port [Integer] the new port, or +nil+ to keep the current value
    # @param secure [Boolean] whether to connect over TLS, or +nil+ to keep the
    #                         current value
    def update_connection(host, port, secure)
      @host = valid! host, valid_host(host), :@host,
                     required: true,
                     required_error: 'networks must have a hostname',
                     invalid_error: 'invalid hostname %s'
      @port = valid! port, valid_port(port), :@port,
                     invalid_error: 'invalid port number %s'
      @secure = valid!(secure, valid_boolean(secure), :@secure,
                       invalid_error: 'secure must be a boolean') { false }
    end

    def server_password=(pass)
      @server_password = valid! pass, valid_string(pass), :@server_password,
                                invalid_error: 'invalid server password %s'
    end

    def nick=(nick)
      @nick = valid! nick, valid_string(nick), :@nick,
                     required: true,
                     required_error: "no nickname for #{@name.inspect} given",
                     invalid_error: 'invalid nickname %s'
    end

    # Updates the SASL authentication details of this network.
    #
    # @param disable [Boolean] whether to disable SASL, or +nil+ to keep the
    #                          current value.
    # @param user [String] the SASL username, or +nil+ to keep the current value
    # @param pass [String] the SASL password, or +nil+ to keep the current value
    def update_sasl(disable, user, pass)
      @sasl_username = valid! user, valid_string(user), :@sasl_username,
                              invalid_error: 'invalid SASL username %s'
      @sasl_password = valid! pass, valid_string(pass), :@sasl_password,
                              invalid_error: 'invalid SASL password %s'
      return unless disable
      @sasl_username = nil
      @sasl_password = nil
    end

    def bind=(bind)
      @bind = valid! bind, valid_string(bind), :@bind,
                     invalid_error: 'invalid bind host %s'
    end

    def modes=(modes)
      @modes = valid! modes, valid_string(modes), :@modes,
                      invalid_error: 'invalid user modes %s'
    end

    # Checks whether the name of this network is equal to another name.
    #
    # @param name [String] the other name
    # @return [Boolean] +true+ if the names are equal, +false+ otherwise
    def name_eql?(name)
      @name.casecmp(name).zero?
    end

    # Returns the port used for connecting to this network, or the default port
    # if no port is set.
    #
    # @return [Integer] the port
    def real_port
      port || (secure ? 6697 : 6667)
    end

    # Checks whether SASL is enabled for this network.
    #
    # @return [Boolean] whether SASL is enabled
    def sasl?
      !sasl_username.to_s.empty? && !sasl_password.to_s.empty?
    end

    # Checks whether this network is equal to another network.
    #
    # @param other [Object] the other network
    # @return [Boolean] +true+ if the networks are equal, +false+ otherwise
    def ==(other)
      other.is_a?(Network) &&
        name_eql?(other.name) &&
        host.eql?(other.host) &&
        port.eql?(other.port) &&
        secure.eql?(other.secure)
    end

    # Generates a hash for this network.
    #
    # @return [Integer] the hash
    def hash
      [name, host, port, secure].hash
    end

    alias eql? ==

    # Serializes this network.
    #
    # @param _conf [Hash] the deserialized configuration
    # @return [Array, Hash] the serialized object
    def serialize(_conf)
      [name, Network.fields.map { |sym| [sym.to_s, send(sym)] }.to_h]
    end

    # Deserializes a network.
    #
    # @param name [String] the name of the network
    # @param data [Hash] the serialized data
    # @return [Hash] the parameters to pass to the initializer
    def self.deserialize(name, data)
      fields.map { |sym| [sym, data[sym.to_s]] }.to_h.merge(name: name)
    end

    # @return [true] to indicate that data is serialized into a hash
    def self.serialize_as_hash?
      true
    end

    # @return [Array<Symbol>] the fields used for serializing this network
    def self.fields
      %i[host port secure server_password nick sasl_username sasl_password
         bind modes]
    end
  end
end
