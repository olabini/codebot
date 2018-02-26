# frozen_string_literal: true

module Codebot
  # This class provides a consistent interface for subclasses that manage a
  # thread.
  class ThreadController
    # Creates a new thread controller.
    def initialize
      @thread = nil
    end

    # Suspends execution of the calling thread until the managed thread exits.
    #
    # @return [Thread, nil] the dead thead, or +nil+ if no thread was active
    def join
      @thread.join if running?
    end

    # Checks whether the managed thread is currently running.
    #
    # @return [Boolean] +true+ if the managed thread is alive,
    #                   +false+ otherwise
    def running?
      !@thread.nil? && @thread.alive?
    end

    # Starts a new managed thread if no thread is currently running.
    # The thread invokes the +run+ method of the class that manages it.
    #
    # @param arg the argument to pass to the +#run+ method
    # @return [Thread, nil] the newly created thread, or +nil+ if
    #                       there was already a running thread
    def start(arg = nil)
      @thread = Thread.new { run(arg) } unless running?
    end

    # Starts a new managed thread. The thread invokes the +run+ method of the
    # class that manages it.
    #
    # @param arg the argument to pass to the +run+ method
    # @return [Thread] the newly created thread
    # @raise [RuntimeError] if there was already a running thread
    def start!(arg = nil)
      raise "#{self.class.name} is already running" unless start(arg)
    end

    # Stops the managed thread if a thread is currently running.
    #
    # @return [Thread, nil] the stopped thread, or +nil+ if
    #                       no thread was running
    def stop
      return unless running?
      @thread.exit
    end

    # Stops the managed thread.
    #
    # @return [Thread] the stopped thread
    # @raise [RuntimeError] if there was no running thread
    def stop!
      raise "#{self.class.name} is already stopped" unless stop
    end
  end
end
