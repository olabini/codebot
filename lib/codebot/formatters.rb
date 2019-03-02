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
require 'codebot/formatters/gitlab_job_hook'
require 'codebot/formatters/gitlab_pipeline_hook'
require 'codebot/formatters/gitlab_note_hook'
require 'codebot/shortener'

module Codebot
  # This module provides methods for formatting outgoing IRC messages.
  module Formatters
    # Formats IRC messages for an event.
    #
    # @param event [Symbol] the webhook event
    # @param payload [Object] the JSON payload object
    # @param color [Boolean] whether to use formatting codes
    # @return [Array<String>] the formatted messages
    def self.format(event, payload, integration, color = true)
      messages = format_color(event, payload, integration).to_a
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

    def self.shortener(inte)
      Shortener::Custom.new(inte.shortener_url, inte.shortener_secret)
    end

    def self.create_formatter(event, payload, integration) # rubocop:disable Metrics/LineLength, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      case event
      when :commit_comment
        Formatters::CommitComment.new(payload, Shortener::Github.new)
      when :fork
        Formatters::Fork.new(payload, Shortener::Github.new)
      when :gollum
        Formatters::Gollum.new(payload, Shortener::Github.new)
      when :issue_comment
        Formatters::IssueComment.new(payload, Shortener::Github.new)
      when :issues
        Formatters::Issues.new(payload, Shortener::Github.new)
      when :ping
        Formatters::Ping.new(payload, Shortener::Github.new)
      when :public
        Formatters::Public.new(payload, Shortener::Github.new)
      when :pull_request
        Formatters::PullRequest.new(payload, Shortener::Github.new)
      when :pull_request_review_comment
        Formatters::PullRequestReviewComment.new(payload, Shortener::Github.new)
      when :push
        Formatters::Push.new(payload, Shortener::Github.new)
      when :watch
        Formatters::Watch.new(payload, Shortener::Github.new)
      when :gitlab_push_hook
        Formatters::Gitlab::PushHook.new(payload, shortener(integration))
      when :gitlab_tag_push_hook
        Formatters::Gitlab::PushHook.new(payload, shortener(integration))
      when :gitlab_job_hook
        Formatters::Gitlab::JobHook.new(payload, shortener(integration))
      when :gitlab_build_hook
        Formatters::Gitlab::JobHook.new(payload, shortener(integration))
      when :gitlab_pipeline_hook
        Formatters::Gitlab::PipelineHook.new(payload, shortener(integration))
      when :gitlab_issue_hook
        Formatters::Gitlab::IssueHook.new(payload, shortener(integration))
      else "Error: missing formatter for #{event.inspect}"
      end
    end

    # Formats colored IRC messages. This method should not be called directly
    # from outside this module.
    #
    # @param event [Symbol] the webhook event
    # @param payload [Object] the JSON payload object
    # @return [Array<String>] the formatted messages
    def self.format_color(event, payload, integration) # rubocop:disable Metrics/LineLength
      create_formatter(event, payload, integration).format
    end
  end
end
