# frozen_string_literal: true

require 'codebot/thread_controller'
require 'codebot/web_listener'
require 'codebot/user_error'

require 'sinatra'

module Codebot
  # This class manages a {WebListener} that runs in a separate thread.
  class WebServer < ThreadController
    extend Sanitizers

    # Creates a new web server.
    #
    # @param core [Core] the bot this server belongs to
    def initialize(core)
      @core = core
    end

    # Starts this web server.
    def run(*)
      create_server.run!
    end

    # Creates a +Proc+ for configuring this web server.
    #
    # @return [Proc] the proc
    def self.configuration
      server = self
      proc do
        disable :traps
        set :bind, ENV['CODEBOT_BIND'] unless ENV['CODEBOT_BIND'].to_s.empty?
        port = ENV['CODEBOT_PORT']
        if port.is_a?(String) && !port.empty?
          set :port, (server.valid! port, server.valid_port(port), nil,
                                    invalid_error: 'invalid port %s')
        end
      end
    end

    private

    # Creates a new Sinatra server for handling incoming requests.
    #
    # @return [Class] the created server
    def create_server
      core = @core
      Sinatra.new do
        include WebListener

        configure { instance_eval(&WebServer.configuration) }
        post('/*') { handle_post(core, request, params) }
        error(Sinatra::NotFound) { [405, 'Method not allowed'] }
      end
    end
  end
end
