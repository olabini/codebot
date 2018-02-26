# frozen_string_literal: true

require 'timeout'

module Codebot
  # A pipe-based IPC client used for communicating with a running Codebot
  # instance.
  class IPCClient
    # @return [String] the path to the named pipe
    attr_reader :pipe

    # Creates a new IPC client.
    #
    # @param pipe [String] the path to the named pipe, or +nil+ to use the
    #                      default pipe for this user
    def initialize(pipe = nil)
      @pipe = pipe || IPCServer.default_pipe
    end

    # Sends a REHASH command to the named pipe.
    #
    # @param explicit [Boolean] whether this command was invoked explicitly
    def send_rehash(explicit = true)
      command('REHASH', explicit)
    end

    # Sends a STOP command to the named pipe.
    #
    # @param explicit [Boolean] whether this command was invoked explicitly
    def send_stop(explicit = true)
      command('STOP', explicit)
    end

    # Checks whether the named pipe exists.
    #
    # @return [Boolean] +true+ if the pipe exists, +false+ otherwise
    def pipe_exist?
      File.pipe? @pipe
    end

    private

    # Sends a command to the named pipe.
    #
    # @param cmd [String] the command
    # @param explicit [Boolean] whether this command was invoked explicitly
    def command(cmd, explicit)
      return unless check_pipe_exist(explicit)
      Timeout.timeout 5 do
        File.open @pipe, 'w' do |p|
          p.puts cmd
        end
      end
    rescue Timeout::Error
      communication_error! 'no response'
    end

    # Checks whether the named pipe exists.
    #
    # @param should_raise [Boolean] whether to raise an exception if the pipe
    #                               does not exist
    # @return [Boolean] +true+ if the pipe exists, +false+ otherwise
    def check_pipe_exist(should_raise)
      return true if pipe_exist?
      communication_error! "missing pipe #{@pipe.inspect}" if should_raise
      false
    end

    # Raise a {CommandError} with a message stating that communication with
    # an active instance failed.
    #
    # @param msg [String] the error message
    # @raise [CommandError] the requested error
    def communication_error!(msg)
      raise CommandError, "unable to communicate with the bot: #{msg} " \
                          '(is the bot running?)'
    end
  end
end
