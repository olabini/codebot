# frozen_string_literal: true

module Codebot
  # This class serves as a parent class for errors caused by the user entering
  # invalid data.
  class UserError < RuntimeError
    def initialize(message)
      super
    end
  end
end
