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
      self.name   = params[:name]
      self.host   = params[:host]
      self.port   = params[:port]
      self.secure = params[:secure]
    end

    def name=(name)
      @name = valid! name, valid_identifier(name), @name,
                     required: true,
                     required_error: 'networks must have a name',
                     invalid_error: 'invalid network name %s'
    end

    def host=(host)
      @host = valid! host, valid_host(host), @host,
                     required: true,
                     required_error: 'networks must have a hostname',
                     invalid_error: 'invalid hostname %s'
    end

    def port=(port)
      @port = valid! port, valid_port(port), @port,
                     invalid_error: 'invalid port number %s'
    end

    def secure=(secure)
      @secure = valid!(secure, valid_boolean(secure), @secure,
                       invalid_error: 'secure must be a boolean') { false }
    end

    # Checks whether the name of this network is equal to another name
    #
    # @param name [String] the name of another network
    # @return [Boolean] +true+ if the names are equal, +false+ otherwise
    def name_eql?(name)
      @name.casecmp(name).zero?
    end

    private_class_method def self.serial_key
      :name
    end

    private_class_method def self.serial_values
      %i[host port secure]
    end
  end
end
