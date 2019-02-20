# frozen_string_literal: true

require 'cinch'
require 'codebot/formatter'
require 'codebot/formatters/commit_comment'
require 'codebot/formatters/fork'
require 'codebot/formatters/gollum'
require 'codebot/formatters/issue_comment'
require 'codebot/formatters/issues'
require 'codebot/formatters/ping'
require 'codebot/formatters/public'
require 'codebot/formatters/pull_request'
require 'codebot/formatters/pull_request_review_comment'
require 'codebot/formatters/push'
require 'codebot/formatters/watch'
require 'codebot/formatters/gitlab_push_hook'
require 'codebot/formatters/gitlab_issue_hook'

module Codebot
  # This module provides methods for formatting outgoing IRC messages.
  module Formatters
    # Formats IRC messages for an event.
    #
    # @param event [Symbol] the webhook event
    # @param payload [Object] the JSON payload object
    # @param color [Boolean] whether to use formatting codes
    # @return [Array<String>] the formatted messages
    def self.format(event, payload, color = true)
      messages = format_color(event, payload).to_a
      messages.map! { |msg| "\x0F" + msg }
      messages.map! { |msg| ::Cinch::Formatting.unformat(msg) } unless color
      messages
    rescue StandardError => e
      STDERR.puts e.message
      STDERR.puts e.backtrace
      url = ::Cinch::Formatting.format(:blue, :underline, FORMATTER_ISSUE_URL)
      ['An error occurred while formatting this message. More information ' \
       "has been printed to STDERR. Please report this issue to #{url}."]
    end

    # Formats colored IRC messages. This method should not be called directly
    # from outside this module.
    #
    # @param event [Symbol] the webhook event
    # @param payload [Object] the JSON payload object
    # @return [Array<String>] the formatted messages
    def self.format_color(event, payload) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/LineLength
      case event
      when :commit_comment then Formatters::CommitComment.new(payload).format
      when :fork then Formatters::Fork.new(payload).format
      when :gollum then Formatters::Gollum.new(payload).format
      when :issue_comment then Formatters::IssueComment.new(payload).format
      when :issues then Formatters::Issues.new(payload).format
      when :ping then Formatters::Ping.new(payload).format
      when :public then Formatters::Public.new(payload).format
      when :pull_request then Formatters::PullRequest.new(payload).format
      when :pull_request_review_comment
        Formatters::PullRequestReviewComment.new(payload).format
      when :push then Formatters::Push.new(payload).format
      when :watch then Formatters::Watch.new(payload).format
      when :gitlab_push_hook then Formatters::Gitlab::PushHook.new(payload).format
      when :gitlab_tag_push_hook then Formatters::Gitlab::PushHook.new(payload).format
      when :gitlab_issue_hook then Formatters::Gitlab::IssueHook.new(payload).format
      else "Error: missing formatter for #{event.inspect}"
      end
    end
  end
end
