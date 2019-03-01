# frozen_string_literal: true

require 'codebot/network_manager'

module Codebot
  module Options
    # A class that handles the +codebot network+ command.
    class Network < Thor
      check_unknown_options!

      # Sets shared options for connecting to the IRC network.
      def self.shared_connection_options
        option :host, aliases: '-H',
                      desc: 'Set the server hostname or address'
        option :port, type: :numeric, aliases: '-p',
                      desc: 'Set the port to connect to'
        option :secure, type: :boolean, aliases: '-s',
                        desc: 'Connect securely using TLS'
        option :server_password, desc: 'Set the server password'
        option :nick, aliases: '-N',
                      desc: 'Set the nickname'
      end

      # Sets shared options for authenticating to the IRC network.
      def self.shared_authentication_options
        # Not a boolean to prevent thor from generating --no-disable-sasl flag
        option :disable_sasl, type: :string, banner: '',
                              desc: 'Disable SASL authentication'
        option :sasl_username, desc: 'Set the username for SASL authentication'
        option :sasl_password, desc: 'Set the password for SASL authentication'

        option :disable_nickserv, type: :string, banner: '',
                                  desc: 'Disable NickServ authentication'
        option :nickserv_username, desc: 'Set the username for NickServ authentication'
        option :nickserv_password, desc: 'Set the password for NickServ authentication'
      end

      # Sets shared options for specifying properties belonging to the
      # {::Codebot::Network} class.
      def self.shared_propery_options
        shared_connection_options
        shared_authentication_options
        option :bind, aliases: '-b',
                      desc: 'Bind to the specified IP address or host'
        option :modes, aliases: '-m',
                       desc: 'Set user modes'
      end

      desc 'create NAME', 'Add a new IRC network'
      shared_propery_options

      # Creates a new network with the specified name.
      #
      # @param name [String] the name of the new network
      def create(name)
        Options.with_core(parent_options, true) do |core|
          NetworkManager.new(core.config).create(options.merge(name: name))
        end
      end

      desc 'update NAME', 'Edit an IRC network'
      option :name, aliases: '-n',
                    banner: 'NEW-NAME',
                    desc: 'Rename this network'
      shared_propery_options

      # Updates the network with the specified name.
      #
      # @param name [String] the name of the network
      def update(name)
        Options.with_core(parent_options, true) do |core|
          NetworkManager.new(core.config).update(name, options)
        end
      end

      desc 'list [SEARCH]', 'List networks'

      # Lists all networks, or networks with names containing the given search
      # term.
      #
      # @param search [String, nil] an optional search term
      def list(search = nil)
        Options.with_core(parent_options, true) do |core|
          NetworkManager.new(core.config).list(search)
        end
      end

      desc 'destroy NAME', 'Delete an IRC network'

      # Destroys the network with the specified name.
      #
      # @param name [String] the name of the network
      def destroy(name)
        Options.with_core(parent_options, true) do |core|
          NetworkManager.new(core.config).destroy(name, options)
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
