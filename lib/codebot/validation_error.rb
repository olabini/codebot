# frozen_string_literal: true

require 'codebot/user_error'

module Codebot
  # This exception stores information about an error that occurred due to a
  # failed validation, for example when a network with an invalid name is
  # created.
  class ValidationError < UserError
    def initialize(message)
      super
    end
  end
end
