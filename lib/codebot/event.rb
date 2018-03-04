# frozen_string_literal: true

module Codebot
  # This module provides methods for processing webhook events.
  module Event
    # The currently supported events.
    VALID_SYMBOLS = %i[
    ].freeze

    # TODO: Support for commit_comment
    # TODO: Support for create
    # TODO: Support for delete
    # TODO: Support for deployment
    # TODO: Support for deployment_status
    # TODO: Support for fork
    # TODO: Support for gollum
    # TODO: Support for installation
    # TODO: Support for installation_repositories
    # TODO: Support for issue_comment
    # TODO: Support for issues
    # TODO: Support for label
    # TODO: Support for marketplace_purchase
    # TODO: Support for member
    # TODO: Support for membership
    # TODO: Support for milestone
    # TODO: Support for organization
    # TODO: Support for org_block
    # TODO: Support for page_build
    # TODO: Support for project_card
    # TODO: Support for project_column
    # TODO: Support for project
    # TODO: Support for public
    # TODO: Support for pull_request_review_comment
    # TODO: Support for pull_request_review
    # TODO: Support for pull_request
    # TODO: Support for push
    # TODO: Support for repository
    # TODO: Support for release
    # TODO: Support for status
    # TODO: Support for team
    # TODO: Support for team_add
    # TODO: Support for watch

    # Converts a webhook event to its corresponding symbol.
    #
    # @param str [String] the event string
    # @return [Symbol, nil] the symbol, or +nil+ if the event is not supported
    def self.symbolize(str)
      VALID_SYMBOLS.find { |sym| sym.to_s.casecmp(str).zero? }
    end
  end
end