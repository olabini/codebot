# frozen_string_literal: true

require 'codebot/thread_controller'
require 'codebot/web_listener'

module Codebot
  # This class manages a {WebListener} that runs in a separate thread.
  class WebServer < ThreadController
    private

    # Starts this web server.
    def run(*)
      WebListener.new.run!
    end
  end
end
