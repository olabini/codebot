# frozen_string_literal: true

module Codebot
  module Formatters
    module Gitlab
      # Triggers on a Note Hook event
      class NoteHook < Formatter
        def format
          ["#{summary}: #{format_url url}"]
        end

        def summary
          case note_type
          when 'Issue'
            issue_summary
          when 'Snippet'
            snippet_summary
          when 'MergeRequest'
            merge_request_summary
          when 'Commit'
            commit_summary
          end
        end

        def issue_summary
          issue_default_format % {
            repository: format_repository(repository_name),
            sender: format_user(sender_name),
            number: issue_number,
            summary: prettify(comment_body)
          }
        end

        def snippet_summary
          snippet_default_format % {
            repository: format_repository(repository_name),
            sender: format_user(sender_name),
            snippet: snippet_title,
            summary: prettify(comment_body)
          }
        end

        def merge_request_summary
          merge_request_default_format % {
            repository: format_repository(repository_name),
            sender: format_user(sender_name),
            mr: merge_request_title,
            summary: prettify(comment_body)
          }
        end

        def commit_summary
          commit_default_format % {
            repository: format_repository(repository_name),
            sender: format_user(sender_name),
            hash: format_hash(commit_id),
            summary: prettify(comment_body)
          }
        end

        def issue_default_format
          '[%<repository>s] %<sender>s commented on issue' \
          ' #%<number>s: %<summary>s'
        end

        def snippet_default_format
          '[%<repository>s] %<sender>s commented on code snippet' \
          ' \'%<snippet>s\': %<summary>s'
        end

        def merge_request_default_format
          '[%<repository>s] %<sender>s commented on merge request' \
          ' \'%<mr>s\': %<summary>s'
        end

        def commit_default_format
          '[%<repository>s] %<sender>s commented on commit' \
          ' %<hash>s: %<summary>s'
        end

        def note_type
          extract(:object_attributes, :noteable_type)
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

        def comment_body
          extract(:object_attributes, :note)
        end

        def snippet_title
          extract(:snippet, :title)
        end

        def merge_request_title
          extract(:merge_request, :title)
        end

        def issue_number
          extract(:issue, :iid)
        end

        def commit_id
          extract(:commit, :id)
        end
      end
    end
  end
end
