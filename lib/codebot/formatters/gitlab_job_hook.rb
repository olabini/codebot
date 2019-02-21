# coding: utf-8

module Codebot
  module Formatters
    module Gitlab
      class JobHook < Formatter
        def format_job_status
          case extract(:build_status)
          when "created"
            "was created from commit:"
          when "success"
            "succeeded"
          when "skipped"
            "was skipped"
          when /^fail/, /^err/
            "failed: #{extract(:build_failure_reason)}"
          else
            "did something: #{extract(:build_status)}"
          end
        end
        
        def format
          repo_url = extract(:repository, :homepage)
          repo_name = extract(:repository, :name)
          job_url = shorten_url "#{repo_url}/-/jobs/#{extract(:build_id)}"
          reply = "[%s] job '%s' (%s)" % [
            format_repository(repo_name),
            extract(:build_name),
            job_url,
            format_job_status,
          ]

          if extract(:build_status) == "created"
            [reply] + [format_commit(extract(:commit))]
          else
            reply
          end
        end

        def format_commit(commit)
          author = commit['author']['name'] if commit['author'].is_a? Hash
          '%<repository>s/%<branch>s %<hash>s %<author>s: %<title>s' % {
            repository: format_repository(repo_name),
            branch: format_branch(branch),
            hash: format_hash(commit['id']),
            author: format_user(author),
            title: prettify(commit["message"]),
          }
        end
      end
    end
  end
end
