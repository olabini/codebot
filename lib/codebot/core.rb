# frozen_string_literal: true

require 'codebot/config'
require 'codebot/irc_client'
require 'codebot/web_server'
require 'codebot/ipc_server'

module Codebot
  # This class represents a {Codebot} bot.
  class Core
    # @return [Config] the configuration used by this bot
    attr_reader :config

    # Creates a new bot from the supplied hash.
    #
    # @param params [Hash] A hash with symbolic keys for initializing this
    #                      instance. The only accepted keys are +:config_file+
    #                      and +:ipc_pipe+. Any other keys are ignored.
    def initialize(params = {})
      @config     = Config.new(params[:config_file])
      @irc_client = IRCClient.new
      @web_server = WebServer.new
      @ipc_server = IPCServer.new(self, params[:ipc_pipe])
    end

    # Starts this bot.
    def start
      @irc_client.start
      @web_server.start
      @ipc_server.start
    end

    # Stops this bot.
    def stop
      @ipc_server.stop
      @web_server.stop
      @irc_client.stop
    end

    # Waits for this bot to stop.
    def join
      @ipc_server.join
      @web_server.join
      @irc_client.join
    end

    # Sets traps for SIGINT and SIGTERM so Codebot can shut down gracefully.
    def trap_signals
      shutdown = proc do |signal|
        puts "\nReceived #{signal}, shutting down..."
        stop
        join
        exit 1
      end
      trap('INT')  { shutdown.call 'SIGINT'  }
      trap('TERM') { shutdown.call 'SIGTERM' }
    end
  end
end
