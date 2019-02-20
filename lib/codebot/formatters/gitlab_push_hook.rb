# coding: utf-8

module Codebot
  module Formatters
    module Gitlab
      class PushHook < Formatter
        def format
          repo_url = extract(:repository, :homepage)
          repo_name = extract(:repository, :name)
          user_name = extract(:user_name)
          commits_count = extract(:total_commits_count).to_i
          branch = extract(:ref).split("/")[2..-1].join("/")

          compare_url = shorten_url "#{repo_url}/compare/#{extract(:before)}...#{extract(:after)}"
          
          reply = "[%s]%s pushed #{format_number commits_count, 'new commit', 'new commits'} to %s: %s" % [
            format_repository(repo_name),
            format_user(user_name),
            format_branch(branch),
            compare_url
          ]
          
          [reply] + extract(:commits).map do |commit|
            author = commit['author']['name'] if commit['author'].is_a? Hash
            '%<repository>s/%<branch>s %<hash>s %<author>s: %<title>s' % {
              repository: repo_name,
              branch: format_branch(branch),
              hash: format_hash(commit['id']),
              author: format_user(author),
              title: prettify(commit["message"]),
              ,
            }
          end
        end
      end
    end
  end
end
