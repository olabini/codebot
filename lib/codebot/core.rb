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

    # @return [IRCClient] the IRC client
    attr_reader :irc_client

    # @return [IRCClient] the web server
    attr_reader :web_server

    # @return [IRCClient] the IPC server
    attr_reader :ipc_server

    # Creates a new bot from the supplied hash.
    #
    # @param params [Hash] A hash with symbolic keys for initializing this
    #                      instance. The only accepted keys are +:config_file+
    #                      and +:ipc_pipe+. Any other keys are ignored.
    def initialize(params = {})
      @config     = Config.new(self, params[:config_file])
      @irc_client = IRCClient.new(self)
      @web_server = WebServer.new(self)
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

    # Waits for this bot to stop. If any of the managed threads finish early,
    # the bot is shut down immediately.
    def join
      ipc = Thread.new { @ipc_server.join && stop }
      web = Thread.new { @web_server.join && stop }
      ipc.join
      web.join
      @irc_client.join
    end

    # Requests that the running threads migrate to an updated configuration.
    def migrate!
      @irc_client.migrate! unless @irc_client.nil?
    end

    # Sets traps for SIGINT and SIGTERM so Codebot can shut down gracefully.
    def trap_signals
      shutdown = proc do |signal|
        STDERR.puts "\nReceived #{signal}, shutting down..."
        stop
        join
        exit 1
      end
      trap('INT')  { shutdown.call 'SIGINT'  }
      trap('TERM') { shutdown.call 'SIGTERM' }
    end
  end
end
