# frozen_string_literal: true

require 'thor'

require 'codebot/options/base'

module Codebot
  # This module provides functionality for parsing command-line options.
  module Options
    # Creates a new {Core} from the specified command-line options. Errors of
    # type {UserError} are handled if they occur in the given block.
    #
    # @param opts [Hash] the options to initialize the core with
    # @param rehash [Boolean] whether to ask a running instance to rehash its
    #                         configuration after invoking the block
    # @yield [Core] the newly created {Core}
    def self.with_core(opts, rehash = false)
      core = ::Codebot::Core.new(
        config_file: opts[:config],
        ipc_pipe:    opts[:pipe]
      )
      with_errors { yield core }
      return unless rehash
      with_ipc_client(opts) do |ipc|
        ipc.send_rehash(!opts[:pipe].nil?)
        puts 'Rehashing the running instance...' unless opts[:quiet]
      end
    end

    # Invokes the given block, handling {UserError} errors.
    def self.with_errors
      yield
    rescue UserError => e
      STDERR.puts "Error: #{e.message}"
      exit 1
    end

    # Creates a new {IPCClient} from the specified command-line options.
    # Errors of type {UserError} are handled if they occur in the given block.
    #
    # @param opts [Hash] the options to initialize the client with
    # @yield [IPCClient] the newly created {IPCClient}
    def self.with_ipc_client(opts)
      with_errors { yield IPCClient.new(opts[:pipe]) }
    end
  end
end
