# frozen_string_literal: true

require 'codebot/thread_controller'

module Codebot
  # This class manages an IRC client that runs in a separate thread.
  class IRCClient < ThreadController
    private

    # Starts this IRC client.
    def run(*)
      # TODO: Not yet implemented
    end
  end
end
