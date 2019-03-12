# frozen_string_literal: true

require 'codebot/command_error'

module Codebot
  # This class manages the networks associated with a configuration.
  class NetworkManager
    # @return [Config] the configuration managed by this class
    attr_reader :config

    # Constructs a new network manager for a specified configuration.
    #
    # @param config [Config] the configuration to manage
    def initialize(config)
      @config = config
    end

    # Creates a new network from the given parameters.
    #
    # @param params [Hash] the parameters to initialize the network with
    def create(params)
      network = Network.new(params.merge(config: {}))
      @config.transaction do
        check_name_available!(network.name)
        @config.networks << network
        network_feedback(network, :created) unless params[:quiet]
      end
    end

    # Updates a network with the given parameters.
    #
    # @param name [String] the current name of the network to update
    # @param params [Hash] the parameters to update the network with
    def update(name, params)
      @config.transaction do
        network = find_network!(name)
        unless params[:name].nil?
          check_name_available_except!(params[:name], network)
        end
        network.update!(params)
        network_feedback(network, :updated) unless params[:quiet]
      end
    end

    # Destroys a network.
    #
    # @param name [String] the name of the network to destroy
    # @param params [Hash] the command-line options
    def destroy(name, params)
      @config.transaction do
        network = find_network!(name)
        @config.networks.delete network
        network_feedback(network, :destroyed) unless params[:quiet]
      end
    end

    # Lists all networks, or networks with names containing the given search
    # term.
    #
    # @param search [String, nil] an optional search term
    def list(search)
      @config.transaction do
        networks = @config.networks.dup
        unless search.nil?
          networks.select! { |net| net.name.downcase.include? search.downcase }
        end
        puts 'No networks found' if networks.empty?
        networks.each { |net| show_network net }
      end
    end

    # Finds a network given its name.
    #
    # @param name [String] the name to search for
    # @return [Network, nil] the network, or +nil+ if none was found
    def find_network(name)
      @config.networks.find { |net| net.name_eql? name }
    end

    # Finds a network given its name.
    #
    # @param name [String] the name to search for
    # @raise [CommandError] if no network with the given name exists
    # @return [Network] the network
    def find_network!(name)
      network = find_network(name)
      return network unless network.nil?

      raise CommandError, "a network with the name #{name.inspect} " \
                          'does not exist'
    end

    # Checks that all channels associated with an integration belong to a valid
    # network.
    #
    # @param integration [Integration] the integration to check
    def check_channels!(integration)
      integration.channels.map(&:network).map(&:name).each do |network|
        find_network!(network)
      end
    end

    private

    # Checks that the specified name is available for use.
    #
    # @param name [String] the name to check for
    # @raise [CommandError] if the name is already taken
    def check_name_available!(name)
      return if name.nil? || !find_network(name)

      raise CommandError, "a network with the name #{name.inspect} " \
                          'already exists'
    end

    # Checks that the specified name is available for use by the specified
    # network.
    #
    # @param name [String] the name to check for
    # @param network [Network] the network to ignore
    # @raise [CommandError] if the name is already taken
    def check_name_available_except!(name, network)
      return if name.nil? || network.name_eql?(name) || !find_network(name)

      raise CommandError, "a network with the name #{name.inspect} " \
                          'already exists'
    end

    # Displays feedback about a change made to a network.
    #
    # @param network [Network] the network
    # @param action [#to_s] the action (+:created+, +:updated+ or +:destroyed+)
    def network_feedback(network, action)
      puts "Network was successfully #{action}"
      show_network(network)
    end

    # Prints information about a network.
    #
    # @param network [Network] the network
    def show_network(network) # rubocop:disable Metrics/AbcSize
      puts "Network: #{network.name}"
      security = "#{network.secure ? 'secure' : 'insecure'} connection"
      password = network.server_password
      puts "\tServer:     #{network.host}:#{network.real_port} (#{security})"
      puts "\tPassword:   #{'*' * password.length}" unless password.to_s.empty?
      puts "\tNickname:   #{network.nick}"
      puts "\tBind to:    #{network.bind}" unless network.bind.to_s.empty?
      puts "\tUser modes: #{network.modes}" unless network.modes.to_s.empty?
      show_network_sasl(network)
      show_network_nickserv(network)
    end

    # Prints information about the SASL authentication settings for a network.
    #
    # @param network [Network] the network
    def show_network_sasl(network)
      puts "\tSASL authentication #{network.sasl? ? 'enabled' : 'disabled'}"
      return unless network.sasl?

      puts "\t\tUsername: #{network.sasl_username}"
      puts "\t\tPassword: #{'*' * network.sasl_password.to_s.length}"
    end

    def nickserv_status(network)
      network.nickserv? ? 'enabled' : 'disabled'
    end

    # Prints information about the NickServ authentication
    #                  settings for a network.
    #
    # @param network [Network] the network
    def show_network_nickserv(network)
      puts "\tNickServ authentication #{nickserv_status(network)}"
      return unless network.nickserv?

      puts "\t\tUsername: #{network.nickserv_username}"
      puts "\t\tPassword: #{'*' * network.nickserv_password.to_s.length}"
    end
  end
end
