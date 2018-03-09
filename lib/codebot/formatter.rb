# frozen_string_literal: true

require 'net/http'
require 'uri'

module Codebot
  # This class formats events.
  class Formatter
    # @return [Object] the JSON payload object
    attr_reader :payload

    # Initializes a new formatter.
    #
    # @param payload [Object] the JSON payload object
    def initialize(payload)
      @payload = payload
    end

    # Formats IRC messages for an unknown event.
    #
    # @return [Array<String>] the formatted messages
    def format
      ['An unknown event occurred']
    end

    # Shortens the summary URL. If this method is used, the child class must
    # implement the +#summary_url+ method.
    #
    # @return [String] the shortened summary URL
    def url
      shorten_url summary_url
    end

    # Formats a repository name.
    #
    # @param repository [String] the name
    # @return [String] the formatted name
    def format_repository(repository)
      ::Cinch::Formatting.format(:pink, repository.to_s)
    end

    # Formats a branch name.
    #
    # @param branch [String] the name
    # @return [String] the formatted name
    def format_branch(branch)
      ::Cinch::Formatting.format(:purple, branch.to_s)
    end

    # Formats a commit hash.
    #
    # @param hash [String] the hash
    # @return [String] the formatted hash
    def format_hash(hash)
      ::Cinch::Formatting.format(:grey, hash.to_s[0..6])
    end

    # Formats a user name.
    #
    # @param user [String] the name
    # @return [String] the formatted name
    def format_user(user)
      ::Cinch::Formatting.format(:silver, user.to_s)
    end

    # Formats a URL.
    #
    # @param url [String] the URL
    # @return [String] the formatted URL
    def format_url(url)
      ::Cinch::Formatting.format(:blue, :underline, url.to_s)
    end

    # Formats a number.
    #
    # @param num [Integer] the number
    # @param singular [String, nil] the singular noun to append to the number
    # @param plural [String, nil] the plural noun to append to the number
    # @return [String] the formatted number
    def format_number(num, singular = nil, plural = nil)
      bold_num = ::Cinch::Formatting.format(:bold, num.to_s)
      (bold_num + ' ' + (num == 1 ? singular : plural).to_s).strip
    end

    # Formats the name of a potentially dangerous operation, such as a deletion
    # or force-push.
    #
    # @param text [String] the text to format
    # @return [String] the formatted text
    def format_dangerous(text)
      ::Cinch::Formatting.format(:red, text.to_s)
    end

    # Extracts the repository name from the payload.
    #
    # @return [String, nil] the repository name
    def repository_name
      extract(:repository, :name)
    end

    # Extracts the repository URL from the payload.
    #
    # @return [String, nil] the repository URL
    def repository_url
      extract(:repository, :url)
    end

    # Extracts the action from the payload.
    #
    # @return [String, nil] the action
    def action
      extract(:action).to_s
    end

    # Checks whether the action is 'opened'.
    #
    # @return [Boolean] whether the action is 'opened'.
    def opened?
      action.eql? 'opened'
    end

    # Checks whether the action is 'closed'.
    #
    # @return [Boolean] whether the action is 'closed'.
    def closed?
      action.eql? 'closed'
    end

    # Extracts the user name of the person who triggered this event.
    #
    # @return [String, nil] the user name
    def sender_name
      extract(:sender, :login)
    end

    # Safely extracts a value from a JSON object.
    #
    # @param path [Array<#to_s>] the path to traverse
    # @return [Object, nil] the extracted object or +nil+ if no object was
    #                       found at the given path
    def extract(*path)
      node = payload
      node if path.all? do |sub|
        break unless node.is_a? Hash
        node = node[sub.to_s]
      end
    end

    # Shortens a URL with GitHub's git.io URL shortener. The domain must belong
    # to GitHub.
    #
    # @param url [String] the long URL
    # @return [String] the shortened URL, or the original URL if an error
    #                  occurred.
    def shorten_url(url)
      return url if url.to_s.empty?
      uri = URI('https://git.io')
      res = Net::HTTP.post_form uri, 'url' => url.to_s
      res['location'] || url.to_s
    rescue StandardError
      url.to_s
    end
  end
end
