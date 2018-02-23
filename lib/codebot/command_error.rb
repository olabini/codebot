# frozen_string_literal: true

require 'codebot/user_error'

module Codebot
  # This exception stores information about an error that occurred due to the
  # user entering an invalid command, for example when two mutually exclusive
  # command-line options are specified.
  class CommandError < UserError
    def initialize(message)
      super
    end
  end
end
