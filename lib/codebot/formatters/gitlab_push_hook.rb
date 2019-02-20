# coding: utf-8
# frozen_string_literal: false

# Portions (c) 2008 Logical Awesome, LLC (released under the MIT license).
# See the LICENSE file for the full MIT license text.

module Codebot
  module Formatters
    module Gitlab
      class PushHook < Formatter # rubocop:disable Metrics/ClassLength
        def format
          repo_url = extract(:repository, :homepage)
          repo_name = extract(:repository, :name)
          user_name = extract(:user_name)
          commits_count = extract(:total_commits_count).to_i
          branch = extract(:ref).split("/")[2..-1].join("/")
          commit_name = "name"
          reply = "\x02\x0306Commit\x03\x02: \x02\x0303%s\x03\x02 - %s pushed %d new commit%s to branch \x02%s\x02:" % [
            repo_name,
            user_name,
            commits_count,
            commits_count == 1 ? "" : "s",
            branch]
          
          [reply] + extract(:commits).map do |commit|
            "\t\x02\x0306～\x03 %s\x02: %s (\x02%s\x02)" % [
              commit["id"][0..7],
              commit["message"].gsub(/[\r\n]/, ''),
              commit["author"][commit_name],
            ]
          end
        end
      end
    end
  end
end
