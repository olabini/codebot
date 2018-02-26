# frozen_string_literal: true

module Codebot
  # A pipe-based IPC server used for communicating with a running Codebot
  # instance.
  class IPCServer < ThreadController
    # @return [Core] the bot this server belongs to
    attr_reader :core

    # @return [String] the path to the named pipe
    attr_reader :pipe

    # Creates a new IPC server.
    #
    # @param core [Core] the bot this server belongs to
    # @param pipe [String] the path to the named pipe, or +nil+ to use the
    #                      default pipe for this user
    def initialize(core, pipe = nil)
      super()
      @core = core
      @pipe = pipe || self.class.default_pipe
    end

    # Stops the managed thread if a thread is currently running, then deletes
    # the named pipe.
    #
    # @return [Thread, nil] the stopped thread, or +nil+ if
    #                       no thread was running
    def stop
      thr = super
      delete_pipe
      thr
    end

    # Returns the path to the default pipe for the current user.
    #
    # @return [String] the path to the named pipe
    def self.default_pipe
      File.join Dir.home, '.codebot.ipc'
    end

    private

    # Creates the named pipe.
    def create_pipe
      return if File.pipe? @pipe
      delete_pipe
      File.mkfifo @pipe
    end

    # Deletes the named pipe.
    def delete_pipe
      File.delete @pipe if File.exist? @pipe
    end

    # Starts this IPC server.
    def run(*)
      create_pipe
      file = File.open @pipe, 'r+'
      while (line = file.gets.strip)
        handle_command line
      end
    ensure
      delete_pipe
    end

    # Handles an incoming IPC command.
    #
    # @param command [String] the command
    def handle_command(command)
      case command
      when 'REHASH'  then @core.config.load!
      when 'STOP'    then Thread.new { @core.stop }
      else STDERR.puts "Unknown IPC command: #{command.inspect}"
      end
    end
  end
end
