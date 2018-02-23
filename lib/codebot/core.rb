# frozen_string_literal: true

require 'codebot/config'
require 'codebot/irc_client'
require 'codebot/web_server'

module Codebot
  # This class represents a {Codebot} bot.
  class Core
    # The configuration associated with this bot
    attr_reader :config

    # Creates a new bot from the supplied hash.
    #
    # @param params [Hash] A hash with symbolic keys for initializing this
    #                      instance. Currently, the only accepted key is
    #                      +:config_file+. Any other keys are ignored.
    def initialize(params = {})
      @config     = Config.new(params[:config_file])
      @web_server = WebServer.new
      @irc_client = IRCClient.new
    end

    # Starts this bot.
    def start!
      @web_server.start!
      @irc_client.start!
    end

    # Stops this bot.
    def stop!
      @web_server.stop!
      @irc_client.stop!
    end

    # Waits for this bot to stop.
    def join
      @web_server.join
      @irc_client.join
    end
  end
end
