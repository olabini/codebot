# frozen_string_literal: true

require 'codebot/thread_controller'

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
    def run(*)
      # TODO: Not yet implemented
    ensure
      # TODO: Not yet implemented
      true
    end
  end
end
