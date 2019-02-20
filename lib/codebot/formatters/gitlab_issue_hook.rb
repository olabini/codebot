# frozen_string_literal: true

module Codebot
  module Formatters
    module Gitlab
      # This class formats issues events.
      class IssueHook < Formatter
        # Formats IRC messages for an issue event.
        #
        # @return [Array<String>] the formatted messages
        def format
          ["#{summary}: #{format_url url}"] if gitlab_opened? || gitlab_closed?
        end

        def summary
          default_format % {
            repository: format_repository(repository_name),
            sender: format_user(extract(:user, :name)),
            action: gitlab_action,
            number: issue_number,
            title: issue_title
          }
        end

        def default_format
          '[%<repository>s] %<sender>s %<action>s issue #%<number>s: %<title>s'
        end

        def summary_url
          extract(:object_attributes, :url).to_s
        end

        def issue_number
          extract(:object_attributes, :id)
        end

        def issue_title
          extract(:object_attributes, :title)
        end
      end
    end
  end
end
