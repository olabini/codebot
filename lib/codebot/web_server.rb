# frozen_string_literal: true

require 'codebot/thread_controller'
require 'codebot/web_listener'

module Codebot
  # This class manages a {WebListener} that runs in a separate thread.
  class WebServer
    include ThreadController

    private

    def run
      WebListener.new.run!
    end
  end
end
