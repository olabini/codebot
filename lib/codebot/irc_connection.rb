# frozen_string_literal: true

require 'codebot/message'
require 'codebot/thread_controller'
require 'codebot/ext/cinch/ssl_extensions'
require 'cinch'

module Codebot
  # This class manages an IRC connection running in a separate thread.
  class IRCConnection < ThreadController
    # @return [Core] the bot this connection belongs to
    attr_reader :core

    # @return [Network] the connected network
    attr_reader :network

    # Constructs a new IRC connection.
    #
    # @param core [Core] the bot this connection belongs to
    # @param network [Network] the network to connect to
    def initialize(core, network)
      @core     = core
      @network  = network
      @messages = Queue.new
      @ready    = Queue.new
    end

    # Schedules a message for delivery.
    #
    # @param message [Message] the message
    def enqueue(message)
      @messages << message
    end

    # Sets this connection to be available for delivering messages.
    def set_ready!
      @ready << true if @ready.empty?
    end

    # Starts a new managed thread if no thread is currently running.
    # The thread invokes the +run+ method of the class that manages it.
    #
    # @return [Thread, nil] the newly created thread, or +nil+ if
    #                       there was already a running thread
    def start(*)
      super(self)
    end

    private

    # Starts this IRC thread.
    #
    # @param connection [IRCConnection] the connection the thread controls
    def run(connection)
      @connection = connection
      bot = create_bot(connection)
      thread = Thread.new { bot.start }
      @ready.pop
      loop { deliver bot, dequeue }
    ensure
      thread.exit unless thread.nil?
    end

    # Dequeue the next message.
    #
    # @return the message
    def dequeue
      @messages.pop
    end

    # Delivers a message to an IRC channel.
    #
    # @param bot [Cinch::Bot] the IRC bot
    # @param message [Message] the message to deliver
    def deliver(bot, message)
      channel = bot.Channel(message.channel.name)
      message.format.to_a.each do |msg|
        channel.send msg
      end
    end

    # Gets the list of channels associated with this network.
    #
    # @param config [Config] the configuration to search
    # @param network [Network] the network to search for
    # @return [Array<Channel>] the list of channels
    def channels(config, network)
      config.integrations.map(&:channels).flatten.select do |channel|
        network == channel.network
      end
    end

    # Gets the list of channel names and keys associated with this network.
    # Each array element is a string containing either the channel name if no
    # key is needed, or the channel name and key, separated by a space.
    #
    # @param config [Config] the configuration to search
    # @param network [Network] the network to search for
    # @return [Array<String>] the list of channel names and keys
    def channel_array(config, network)
      channels(config, network).map do |channel|
        "#{channel.name} #{channel.key}".strip
      end
    end

    # Constructs a new bot for the given IRC network.
    #
    # @param con [IRCConnection] the connection the thread controls
    def create_bot(con) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      net = con.network
      chan_ary = channel_array(con.core.config, network)
      Cinch::Bot.new do
        configure do |c|
          c.channels      = chan_ary
          c.local_host    = net.bind
          c.modes         = net.modes.to_s.gsub(/\A\+/, '').chars.uniq
          c.nick          = net.nick
          c.password      = net.server_password
          c.port          = net.real_port
          c.realname      = Codebot::WEBSITE
          if net.sasl?
            c.sasl.username = net.sasl_username
            c.sasl.password = net.sasl_password
          end
          c.server        = net.host
          c.ssl.use       = net.secure
          c.ssl.verify    = net.secure
          c.user          = Codebot::PROJECT.downcase
        end

        on(:join) { con.set_ready! }
      end
    end
  end
end
