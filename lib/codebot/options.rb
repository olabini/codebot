# frozen_string_literal: true

require 'thor'

require 'codebot/options/base'

module Codebot
  # This module provides functionality for parsing command-line options.
  module Options
    # Creates a new {Core} from the specified command-line options.
    #
    # @return [Core] the newly created {Core}.
    def self.with_core(opts)
      core = Core.new(config_file: opts[:config])
      begin
        yield core
      rescue UserError => e
        STDERR.puts "Error: #{e.message}"
        exit 1
      end
    end
  end
end
