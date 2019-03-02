# frozen_string_literal: true

module Codebot
  module Formatters
    module Gitlab
      # Triggers on a Job or Build event
      class JobHook < Formatter
        def format_job_status # rubocop:disable Metrics/MethodLength
          case extract(:build_status)
          when 'created'
            'was created from commit:'
          when 'success'
            'succeeded'
          when 'skipped'
            'was skipped'
          when /^fail/, /^err/
            "failed: #{extract(:build_failure_reason)}"
          else
            "did something: #{extract(:build_status)}"
          end
        end

        def repo_url
          extract(:repository, :homepage)
        end

        def repo_name
          extract(:repository, :name)
        end

        def job_url
          shorten_url "#{repo_url}/-/jobs/#{extract(:build_id)}"
        end

        def job_description
          '[%<repository>s] job \'%<build>s\' (%<url>s) %<status>s' % {
            repository: format_repository(repo_name),
            build: extract(:build_name),
            url: job_url,
            status: format_job_status
          }
        end

        def format
          if extract(:build_status) == 'created'
            [job_description] + [format_commit(extract(:commit))]
          else
            [job_description]
          end
        end

        def author(commit)
          return nil unless commit['author'].is_a? Hash

          commit['author']['name']
        end

        def branch
          pieces = extract(:ref).split('/')
          return pieces[0] if pieces.length == 1

          pieces[2..-1].join('/')
        end

        def format_commit(commit)
          '%<repository>s/%<branch>s %<hash>s %<author>s: %<title>s' % {
            repository: format_repository(repo_name),
            branch: format_branch(branch),
            hash: format_hash(commit['id']),
            author: format_user(author(commit)),
            title: prettify(commit['message'])
          }
        end
      end
    end
  end
end
