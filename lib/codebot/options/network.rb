# frozen_string_literal: true

require 'codebot/network_manager'

module Codebot
  module Options
    # A class that handles the +codebot network+ command.
    class Network < Thor
      check_unknown_options!

      # Sets shared options for specifying properties belonging to the
      # {::Codebot::Network} class.
      def self.shared_propery_options
        option :host, aliases: '-H',
                      desc: 'Set the server hostname or address'
        option :port, type: :numeric, aliases: '-p',
                      desc: 'Set the port to connect to'
        option :secure, type: :boolean, aliases: '-s',
                        desc: 'Connect securely using TLS'
      end

      desc 'create NAME', 'Add a new IRC network'
      shared_propery_options

      # Creates a new network with the specified name.
      #
      # @param name [String] the name of the new network
      def create(name)
        Options.with_core(parent_options, true) do |core|
          NetworkManager.new(core.config).create(
            name:   name,
            host:   options[:host],
            port:   options[:port],
            secure: options[:secure]
          )
        end
      end

      desc 'update NAME', 'Edit an IRC network'
      option :rename, aliases: '-n',
                      banner: 'NEW-NAME',
                      desc: 'Rename this network'
      shared_propery_options

      # Updates the network with the specified name.
      #
      # @param name [String] the name of the network
      def update(name)
        Options.with_core(parent_options, true) do |core|
          NetworkManager.new(core.config).update(
            name,
            name:   options[:rename],
            host:   options[:host],
            port:   options[:port],
            secure: options[:secure]
          )
        end
      end

      desc 'destroy NAME', 'Delete an IRC network'

      # Destroys the network with the specified name.
      #
      # @param name [String] the name of the network
      def destroy(name)
        Options.with_core(parent_options, true) do |core|
          NetworkManager.new(core.config).destroy(name)
        end
      end

      # Ensures that thor uses the correct exit code.
      #
      # @return true
      def self.exit_on_failure?
        true
      end
    end
  end
end
