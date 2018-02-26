# frozen_string_literal: true

require 'codebot/thread_controller'

module Codebot
  # This class manages an IRC client that runs in a separate thread.
  class IRCClient < ThreadController
    # Constructs a new IRC client.
    def initialize
      @requests = Queue.new
    end

    # Dispatches a new request.
    #
    # @param request [Request] the request to dispatch
    def dispatch(request)
      @requests << request
    end

    private

    # Starts this IRC client.
    def run(*)
      # TODO: Not yet implemented
    end
  end
end
