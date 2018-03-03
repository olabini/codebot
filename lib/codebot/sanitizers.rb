# frozen_string_literal: true

require 'codebot/cryptography'
require 'codebot/validation_error'

module Codebot
  # This module provides data sanitization methods shared among multiple
  # classes.
  module Sanitizers
    # Sanitizes an identifier.
    #
    # @param identifier [String, nil] the identifier to sanitize
    # @return [String, nil] the sanitized value or +nil+ on error
    def valid_identifier(identifier)
      identifier.downcase if /\A[[:alnum:]\-_]+\z/.match? identifier
    end

    # Sanitizes an endpoint name.
    #
    # @param endpoint [String, nil] the endpoint name to sanitize
    # @return [String, nil] the sanitized value or +nil+ on error
    def valid_endpoint(endpoint)
      endpoint if /\A[[:alnum:]\-_]*\z/.match? endpoint
    end

    # Sanitizes a webhook secret.
    #
    # @param secret [String, nil] the webhook secret to sanitize
    # @return [String, nil] the sanitized value or +nil+ on error
    def valid_secret(secret)
      secret if /\A[[:print:]]*\z/.match? secret
    end

    # Sanitizes a hostname.
    #
    # @param host [String, nil] the hostname to sanitize
    # @return [String, nil] the sanitized value or +nil+ on error
    def valid_host(host)
      host if /\A[[:graph:]]+\z/.match? host
    end

    # Sanitizes a TCP/IP port number.
    #
    # @param port [#to_i, #to_s] the port number to sanitize
    # @return [Integer, nil] the sanitized value or +nil+ on error
    def valid_port(port)
      port_number = port.to_s.to_i(10) if /\A[0-9]+\z/.match?(port.to_s)
      port_number if (1...2**16).cover? port_number
    end

    # Sanitizes a boolean value.
    #
    # @param bool [Boolean, nil] the boolean to sanitize
    # @return [Boolean, nil] the sanitized value or +nil+ on error
    def valid_boolean(bool)
      bool if [true, false].include? bool
    end

    # Sanitizes a string.
    #
    # @param str [String, nil] the string to sanitize
    # @return [String, nil] the sanitized value or +nil+ on error
    def valid_string(str)
      str if str.is_a? String
    end

    # Sanitizes a channel name.
    #
    # @param channel [String, nil] the channel name to sanitize
    # @return [String, nil] the sanitized value or +nil+ on error
    def valid_channel_name(channel)
      # Colons are currently not considered valid characters because some IRCds
      # use them to delimit channel masks. This might change in the future.
      channel if /\A[&#\+!][[:graph:]&&[^:,]]{,49}\z/.match? channel
    end

    # Sanitizes a channel key.
    #
    # @param key [String, nil] the channel key to sanitize
    # @return [String, nil] the sanitized value or +nil+ on error
    def valid_channel_key(key)
      key if /\A[[:graph:]&&[^,]]*\z/.match? key
    end

    # Sanitizes a network name.
    #
    # @param name [String] the name of the network
    # @param conf [Hash] the configuration containing all networks
    # @return [Network, nil] the corresponding network or +nil+ on error
    def valid_network(name, conf)
      return if name.nil?
      conf[:networks].find { |net| net.name_eql? name }
    end

    # This method requires a validation to succeed, raising an exception if it
    # does not. If no original value was provided, it returns, in this order,
    # the given fallback, the return value of any block passed to this method,
    # or, finally, +nil+, unless the +:required+ option is set, in which case
    # a +ValidationError+ is raised.
    #
    # @param original [Object] the original value
    # @param sanitized [Object] the sanitized value
    # @param fallback [Object] an optional symbol representing an instance
    #                          variable to be returned when the original value
    #                          is +nil+
    # @raise [ValidationError] if the sanitization failed. The error message may
    #                          be set using the +:invalid_error+ option.
    # @raise [ValidationError] if the +:required+ option is set, but neither an
    #                          original value nor a fallback value was specified
    #                          and no block was given. The error message may be
    #                          set using the +:required_error+ option.
    # @param options [Hash] a hash optionally containing additional settings.
    def valid!(original, sanitized, fallback = nil, options = {})
      return sanitized unless sanitized.nil?
      unless original.nil?
        raise ValidationError, options[:invalid_error] % original.inspect
      end
      return instance_variable_get(fallback) if fallback_exist?(fallback)
      return yield if block_given?
      raise ValidationError, options[:required_error] if options[:required]
    end

    private def fallback_exist?(fallback)
      !fallback.nil? && instance_variable_defined?(fallback)
    end
  end
end
