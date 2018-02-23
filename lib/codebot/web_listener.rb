# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module Codebot
  # This module provides methods for processing incoming webhooks.
  module WebListener
    # Constructs a web server that listens to incoming webhooks and forwards
    # them to the appropriate integration.
    #
    # @return [#run!] the web server
    def self.new
      Sinatra.new do
        # TODO: Not yet implemented
        post '/endpoint' do
          [501, 'Not implemented']
        end
      end
    end
  end
end
