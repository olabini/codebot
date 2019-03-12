# frozen_string_literal: true

module Codebot
  module Formatters
    module Gitlab
      # Triggers on a Wiki Page Hook event
      class WikiPageHook < Formatter
        def format
          ["#{summary}: #{format_url url}"]
        end

        def summary
          default_format % {
            repository: format_repository(repository_name),
            sender: format_user(sender_name),
            action: action,
            title: wiki_title
          }
        end

        def default_format
          '[%<repository>s] %<sender>s %<action>s page \'%<title>s\''
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
          case wiki_action
          when 'create' then 'created'
          when 'delete' then 'deleted'
          when 'update', nil then 'updated'
          else wiki_action
          end
        end

        def wiki_action
          extract(:object_attributes, :action)
        end

        def wiki_title
          extract(:object_attributes, :title)
        end
      end
    end
  end
end
