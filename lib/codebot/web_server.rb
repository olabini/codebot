# frozen_string_literal: true

require 'codebot/thread_controller'
require 'codebot/web_listener'

require 'sinatra'

module Codebot
  # This class manages a {WebListener} that runs in a separate thread.
  class WebServer < ThreadController
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

    private

    # Creates a new Sinatra server for handling incoming requests.
    #
    # @return [Class] the created server
    def create_server
      core = @core
      Sinatra.new do
        include WebListener

        post '/*' do
          handle_post(core, request, params)
        end

        error Sinatra::NotFound do
          [405, 'Method Not Allowed']
        end
      end
    end
  end
end
