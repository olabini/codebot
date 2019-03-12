# frozen_string_literal: true

require 'psych'

require 'codebot/channel'
require 'codebot/integration'
require 'codebot/network'

module Codebot
  # This class manages a Codebot configuration file.
  class Config
    # @return [Core] the bot this configuration belongs to
    attr_reader :core

    # @return [String] the path to the managed configuration file
    attr_reader :file

    # Creates a new instance of the class and loads the configuration file.
    #
    # @param core [Core] the bot this configuration belongs to
    # @param file [String] the path to the configuration file, or +nil+ to
    #                      use the default configuration file for this user
    def initialize(core, file = nil)
      @core = core
      @file = file || self.class.default_file
      @semaphore = Mutex.new
      unsafe_load
    end

    # Loads the configuration from the associated file. If the file does not
    # exist, it is created.
    def load!
      transaction { unsafe_load }
    end

    # A thread-safe method for making changes to the configuration. If another
    # transaction is active, the calling thread waits for it to complete.
    # If a +StandardError+ occurs during the transaction, the configuration
    # is rolled back to the previous state.
    #
    # @yield invokes the given block during the transaction
    # @raise [StandardError] the error that occurred during modification
    # @return [true] if the transaction completes successfully
    def transaction
      @semaphore.synchronize do
        state = @conf
        begin
          run_transaction(&Proc.new)
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

    # Returns the path to the default configuration file for the current user.
    #
    # @return [String] the path to the configuration file
    def self.default_file
      File.join Dir.home, '.codebot.yml'
    end

    private

    # Saves the current configuration to the configuration file.
    def save!
      save_to_file! @file
    end

    # Loads the configuration file without starting a transaction.
    def unsafe_load
      @conf = load_from_file! @file
      save! unless File.file? @file
    end

    # Makes changes to the configuration, saves the file and requests that the
    # bot migrate to the new version.
    #
    # @note This method should only be called by the {#transaction} method.
    # @return [Boolean] +true+ if the transaction succeeded, +false+ otherwise
    def run_transaction
      yield
      return false unless save!

      @core.migrate!
      true
    end

    # Loads the configuration from the specified file.
    #
    # @param file [String] the path to the configuration file
    # @return [Hash] the loaded configuration, or the default configuration if
    #                the file did not exist
    def load_from_file!(file)
      data = Psych.safe_load(File.read(file)) if File.file? file
      data = {} unless data.is_a? Hash
      conf = {}
      conf[:networks]     = Network.deserialize_all data['networks'], conf
      conf[:integrations] = Integration.deserialize_all data['integrations'],
                                                        conf
      conf
    end

    # Saves the configuration to the specified file.
    #
    # @param file [String] the path to the configuration file
    def save_to_file!(file)
      data = {}
      data['networks']     = Network.serialize_all     @conf[:networks], @conf
      data['integrations'] = Integration.serialize_all @conf[:integrations],
                                                       @conf
      File.write file, Psych.dump(data)
    end
  end
end
