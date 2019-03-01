# frozen_string_literal: false

module Codebot
  module Formatters
    module Gitlab
      # This class formats Push events from Gitlab
      class PushHook < Formatter
        def before_commit
          extract(:before)
        end

        def after_commit
          extract(:after)
        end

        def repository_name
          extract(:repository, :name)
        end

        def repository_url
          extract(:repository, :homepage)
        end

        def compare_url
          commits = "#{before_commit}...#{before_commit}"
          shorten_url "#{repository_url}/compare/#{commits}"
        end

        def commit_default_format
          '%<repository>s/%<branch>s %<hash>s %<author>s: %<title>s'
        end

        def commit_author(commit)
          return nil unless commit['author'].is_a? Hash

          commit['author']['name']
        end

        def commit_summary(commit)
          commit_default_format % {
            repository: format_repository(repository_name),
            branch: format_branch(branch),
            hash: format_hash(commit['id']),
            author: format_user(commit_author(commit)),
            title: prettify(commit['message'])
          }
        end

        def branch
          extract(:ref).split('/')[2..-1].join('/')
        end

        def num_commits
          format_number(extract(:total_commits_count).to_i,
                        'new commit', 'new commits')
        end

        def summary_format
          '[%<repository>s] %<user>s pushed %<num_commits>s ' \
            'to %<branch>s: %<url>s'
        end

        def default_summary
          user_name = extract(:user_name)

          summary_format % {
            repository: format_repository(repository_name),
            user: format_user(user_name),
            num_commits: num_commits,
            branch: format_branch(branch),
            url: compare_url
          }
        end

        def format
          [default_summary] + extract(:commits).map do |commit|
            commit_summary(commit)
          end
        end
      end
    end
  end
end
