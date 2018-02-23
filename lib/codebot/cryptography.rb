# frozen_string_literal: true

require 'securerandom'

module Codebot
  # This module provides convenience methods for performing cryptographic
  # operations.
  module Cryptography
    # Generates a random name for an integration endpoint.
    #
    # @return [String] the generated name
    def self.generate_endpoint
      SecureRandom.uuid
    end

    # Generates a random webhook secret.
    #
    # @return [String] the generated secret
    def self.generate_secret(len = 32)
      SecureRandom.base64(len || 32)
    end
  end
end
