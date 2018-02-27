# frozen_string_literal: true

require 'codebot/thread_controller'
require 'codebot/ext/cinch/ssl_extensions'
require 'cinch'

module Codebot
  # This class manages an IRC connection running in a separate thread.
  class IRCConnection < ThreadController
    # @return [Network] the connected network
    attr_reader :network

    # Constructs a new IRC connection.
    def initialize(network)
      @network  = network
      @requests = Queue.new
    end

    # Handles a request.
    #
    # @param request [Request] the request to handle
    def handle(request)
      @requests << request
    end

    private

    # Starts this IRC thread.
    def run(network)
      create_bot(network).start
    end

    # Constructs a new bot for the given IRC network.
    def create_bot(net) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      Cinch::Bot.new do
        configure do |c|
          c.local_host    = net.bind
          c.modes         = net.modes.gsub(/\A\+/, '').chars.uniq
          c.nick          = net.nick
          c.password      = net.server_password
          c.port          = net.port || (net.secure ? 6697 : 6667)
          c.realname      = Codebot::WEBSITE
          c.sasl.username = net.sasl_username
          c.sasl.password = net.sasl_password
          c.server        = net.host
          c.ssl.use       = net.secure
          c.ssl.verify    = net.secure
          c.user          = Codebot::PROJECT.downcase
        end
      end
    end
  end
end
