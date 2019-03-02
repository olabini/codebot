# frozen_string_literal: true

module Codebot
  module Formatters
    module Gitlab
      # Triggers on a Merge Request Hook event
      class MergeRequestHook < Formatter
        def format
          ["#{summary}: #{format_url url}"]
        end

        def summary
          default_format % {
            repository: format_repository(repository_name),
            sender: format_user(sender_name),
            action: action,
            title: pull_title
          }
        end

        def default_format
          '[%<repository>s] %<sender>s %<action>s merge request \'%<title>s\''
        end

        def repository_name
          extract(:project, :path_with_namespace)
        end

        def sender_name
          extract(:user, :name)
        end

        def summary_url
          extract(:object_attributes, :url)
        end

        def action
          case pull_action
          when 'open' then 'opened'
          when 'close' then 'closed'
          when 'reopen' then 'reopened'
          when 'update', nil then 'updated'
          else pull_action
          end
        end

        def pull_action
          extract(:object_attributes, :action)
        end

        def pull_title
          extract(:object_attributes, :title)
        end
      end
    end
  end
end
