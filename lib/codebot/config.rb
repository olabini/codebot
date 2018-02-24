# frozen_string_literal: true

require 'psych'

require 'codebot/channel'
require 'codebot/integration'
require 'codebot/network'

module Codebot
  # This class manages a Codebot configuration file.
  class Config
    # @return [String] the path to the managed configuration file
    attr_reader :file

    # Creates a new instance of the class and loads the configuration file.
    #
    # @param file [String] The path to the configuration file, or +nil+ to
    #                      use the default configuration file for this user.
    def initialize(file = nil)
      @file = file || default_file
      @semaphore = Mutex.new
      load!
    end

    # Saves the current configuration to the configuration file.
    def save!
      save_to_file!(@file)
    end

    # A thread-safe method for making changes to the configuration. If another
    # transaction is active, the calling thread blocks until it completes.
    # If a +StandardError+ occurs during the transaction, the configuration
    # is rolled back to the previous state.
    #
    # @yield [Config] Passes +self+ to the block
    # @raise [StandardError] the error that occurred during modification
    # @return [true] if the transaction completes successfully
    def transaction
      @semaphore.synchronize do
        state = @conf
        begin
          yield self
          true if save!
        rescue StandardError
          @conf = state
          raise
        end
      end
    end

    # @return [Array] the integrations contained in this configuration
    def integrations
      @conf[:integrations]
    end

    # @return [Array] the networks contained in this configuration
    def networks
      @conf[:networks]
    end

    private

    def load!
      @conf = load_from_file! @file
      save! unless File.file? @file
    end

    def load_from_file!(file)
      data = Psych.safe_load(File.read(file)) if File.file? file
      data = {} unless data.is_a? Hash
      conf = {}
      conf[:integrations] = Integration.load_all! data['integrations']
      conf[:networks]     = Network.load_all!     data['networks']
      conf
    end

    def save_to_file!(file)
      data = {}
      data['integrations'] = Integration.save_all! @conf[:integrations]
      data['networks']     = Network.save_all!     @conf[:networks]
      File.write file, Psych.dump(data)
    end

    def default_file
      File.join Dir.home, '.codebot.yml'
    end
  end
end
