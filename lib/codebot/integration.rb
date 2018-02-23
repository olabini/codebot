# frozen_string_literal: true

require 'codebot/serializable'

module Codebot
  # This class represents an integration that maps an endpoint to the
  # corresponding IRC channels.
  class Integration < Serializable
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
      @name     = params[:name]
      @endpoint = params[:endpoint]
      @secret   = params[:secret]
      @channels = params[:channels]
    end

    private_class_method def self.serial_key
      :name
    end

    private_class_method def self.serial_values
      %i[endpoint secret channels]
    end
  end
end
