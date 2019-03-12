# frozen_string_literal: true

module Codebot
  module Formatters
    module Gitlab
      # This class formats issues events.
      class IssueHook < Formatter
        def issue_action
          extract(:object_attributes, :action)
        end

        def format_issue_action
          case issue_action
          when 'open' then 'opened'
          when 'close' then 'closed'
          when 'reopen' then 'reopened'
          when 'update', nil then 'updated'
          else issue_action
          end
        end

        def repo_url
          extract(:project, :web_url)
        end

        def repo_name
          extract(:project, :path_with_namespace)
        end

        def issue_url
          shorten_url extract(:object_attributes, :url)
        end

        def user_name
          extract(:user, :name)
        end

        def default_format
          '[%<repository>s] %<sender>s %<action>s issue #%<number>s:' \
            ' %<title>s: %<url>s'
        end

        def format
          [default_format % {
            repository: format_repository(repo_name),
            sender: format_user(user_name),
            action: format_issue_action,
            number: extract(:object_attributes, :iid),
            title: extract(:object_attributes, :title),
            url: issue_url
          }]
        end
      end
    end
  end
end
