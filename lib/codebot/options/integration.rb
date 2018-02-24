# frozen_string_literal: true

require 'codebot/integration_manager'

module Codebot
  module Options
    # A class that handles the +codebot integration+ command.
    class Integration < Thor
      check_unknown_options!

      # Sets shared options for specifying properties belonging to the
      # {::Codebot::Integration} class.
      def self.shared_propery_options
        option :endpoint, aliases: '-e',
                          desc: 'Set the endpoint for incoming webhooks'
        option :secret, aliases: '-s',
                        desc: 'Set the secret for verifying webhook payloads'
      end

      desc 'create NAME', 'Add a new integration'
      shared_propery_options
      option :channels, aliases: '-c', type: :array,
                        desc: 'Set the channels to deliver notifications to'

      # Creates a new integration with the specified name.
      #
      # @param name [String] the name of the new integration
      def create(name)
        Options.with_core(parent_options) do |core|
          options[:name] = name
          map_channels!(options, :channels)
          IntegrationManager.new(core.config).create(options)
        end
      end

      desc 'update NAME', 'Edit an integration'
      option :rename, aliases: '-n',
                      banner: 'NEW-NAME',
                      desc: 'Rename this integration'
      shared_propery_options
      option :add_channels, aliases: '-a', type: :array,
                            desc: 'Add channels to this integration'
      option :clear_channels, aliases: '-c', type: :boolean,
                              desc: 'Clear the channel list ' \
                                    '(default: false)'
      option :delete_channels, aliases: '-d', type: :array,
                               desc: 'Delete channels from this integration'

      # Updates the integration with the specified name.
      #
      # @param name [String] the name of the integration
      def update(name)
        Options.with_core(parent_options) do |core|
          map_channels!(options, :add_channels)
          IntegrationManager.new(core.config).update(name, options)
        end
      end

      desc 'destroy NAME', 'Delete an integration'

      # Destroys the integration with the specified name.
      #
      # @param name [String] the name of the integration
      def destroy(name)
        Options.with_core(parent_options) do |core|
          IntegrationManager.new(core.config).destroy(name)
        end
      end

      def self.exit_on_failure?
        true
      end

      private

      # Destructively converts an array of channel identifiers contained in a
      # hash into the serialized form of the channels contained in the array.
      # If the value +hash[key]+ is +nil+, no action is taken.
      #
      # @param hash [Hash] the hash containing the array of identifiers
      # @param key [Object] the key corresponding to the array of identifiers
      def map_channels!(hash, key)
        hash[key] = hash[key].map { |id| [id, {}] }.to_h unless hash[key].nil?
      end
    end
  end
end
