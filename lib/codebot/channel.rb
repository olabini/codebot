# frozen_string_literal: true

require 'codebot/serializable'

module Codebot
  # This class represents an IRC channel notifications can be delivered to.
  class Channel < Serializable
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
    #                      +:network+ are required.
    def initialize(params)
      @name          = params[:name]
      @network       = params[:network]
      @key           = params[:key]
      @send_external = params[:send_external]
    end

    private_class_method def self.serial_key
      :name
    end

    private_class_method def self.serial_values
      %i[network key send_external]
    end
  end
end
