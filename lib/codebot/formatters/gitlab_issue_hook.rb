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
          when "open"
            "opened"
          when "close"
            "closed"
          when "reopen"
            "reopened"
          when "update", nil
            "updated"
          else
            issue_action
          end
        end

        def format
          repo_url = extract(:project, :web_url)
          repo_name = extract(:project, :path_with_namespace)
          issue_url = shorten_url extract(:object_attribtes, :url)
          user_name = extract(:user, :name)

          '[%<repository>s] %<sender>s %<action>s issue #%<number>s: %<title>s: %<url>s' % {
            repository: format_repository(repo_name),
            sender: format_user(user_name),
            action: format_issue_action,
            number: extract(:object_attributes, :iid),
            title: extract(:object_attributes, :title),
            url: issue_url,
          }
        end
      end
    end
  end
end

# {
#   "object_kind": "issue",
#   "user": {
#     "name": "Administrator",
#     "username": "root",
#     "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
#   },
#   "project": {
#     "id": 1,
#     "name":"Gitlab Test",
#     "description":"Aut reprehenderit ut est.",
#     "web_url":"http://example.com/gitlabhq/gitlab-test",
#     "avatar_url":null,
#     "git_ssh_url":"git@example.com:gitlabhq/gitlab-test.git",
#     "git_http_url":"http://example.com/gitlabhq/gitlab-test.git",
#     "namespace":"GitlabHQ",
#     "visibility_level":20,
#     "path_with_namespace":"gitlabhq/gitlab-test",
#     "default_branch":"master",
#     "homepage":"http://example.com/gitlabhq/gitlab-test",
#     "url":"http://example.com/gitlabhq/gitlab-test.git",
#     "ssh_url":"git@example.com:gitlabhq/gitlab-test.git",
#     "http_url":"http://example.com/gitlabhq/gitlab-test.git"
#   },
#   "repository": {
#     "name": "Gitlab Test",
#     "url": "http://example.com/gitlabhq/gitlab-test.git",
#     "description": "Aut reprehenderit ut est.",
#     "homepage": "http://example.com/gitlabhq/gitlab-test"
#   },
#   "object_attributes": {
#     "id": 301,
#     "title": "New API: create/update/delete file",
#     "assignee_ids": [51],
#     "assignee_id": 51,
#     "author_id": 51,
#     "project_id": 14,
#     "created_at": "2013-12-03T17:15:43Z",
#     "updated_at": "2013-12-03T17:15:43Z",
#     "position": 0,
#     "branch_name": null,
#     "description": "Create new API for manipulations with repository",
#     "milestone_id": null,
#     "state": "opened",
#     "iid": 23,
#     "url": "http://example.com/diaspora/issues/23",
#     "action": "open"
#   },
#   "assignees": [{
#     "name": "User1",
#     "username": "user1",
#     "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
#   }],
#   "assignee": {
#     "name": "User1",
#     "username": "user1",
#     "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
#   },
#   "labels": [{
#     "id": 206,
#     "title": "API",
#     "color": "#ffffff",
#     "project_id": 14,
#     "created_at": "2013-12-03T17:15:43Z",
#     "updated_at": "2013-12-03T17:15:43Z",
#     "template": false,
#     "description": "API related issues",
#     "type": "ProjectLabel",
#     "group_id": 41
#   }],
#   "changes": {
#     "updated_by_id": [null, 1],
#     "updated_at": ["2017-09-15 16:50:55 UTC", "2017-09-15 16:52:00 UTC"],
#     "labels": {
#       "previous": [{
#         "id": 206,
#         "title": "API",
#         "color": "#ffffff",
#         "project_id": 14,
#         "created_at": "2013-12-03T17:15:43Z",
#         "updated_at": "2013-12-03T17:15:43Z",
#         "template": false,
#         "description": "API related issues",
#         "type": "ProjectLabel",
#         "group_id": 41
#       }],
#       "current": [{
#         "id": 205,
#         "title": "Platform",
#         "color": "#123123",
#         "project_id": 14,
#         "created_at": "2013-12-03T17:15:43Z",
#         "updated_at": "2013-12-03T17:15:43Z",
#         "template": false,
#         "description": "Platform related issues",
#         "type": "ProjectLabel",
#         "group_id": 41
#       }]
#     }
#   }
# }

# {
#   "object_kind": "issue",
#   "event_type": "issue",
#   "user": {
#     "name": "Ola Bini",
#     "username": "ola",
#     "avatar_url": "https://gitlab.autonomia.digital/uploads/-/system/user/avatar/7/avatar.png"
#   },
#   "project": {
#     "id": 15,
#     "name": "website-autonomia.digital",
#     "description": "This is the repository of Centro de Autonomia Digital homepage",
#     "web_url": "https://gitlab.autonomia.digital/infrastructure/website-autonomia.digital",
#     "avatar_url": null,
#     "git_ssh_url": "git@gitlab.autonomia.digital:infrastructure/website-autonomia.digital.git",
#     "git_http_url": "https://gitlab.autonomia.digital/infrastructure/website-autonomia.digital.git",
#     "namespace": "Infrastructure",
#     "visibility_level": 0,
#     "path_with_namespace": "infrastructure/website-autonomia.digital",
#     "default_branch": "master",
#     "ci_config_path": "",
#     "homepage": "https://gitlab.autonomia.digital/infrastructure/website-autonomia.digital",
#     "url": "git@gitlab.autonomia.digital:infrastructure/website-autonomia.digital.git",
#     "ssh_url": "git@gitlab.autonomia.digital:infrastructure/website-autonomia.digital.git",
#     "http_url": "https://gitlab.autonomia.digital/infrastructure/website-autonomia.digital.git"
#   },
#   "object_attributes": {
#     "author_id": 7,
#     "closed_at": "2018-04-12 07:26:47 UTC",
#     "confidential": false,
#     "created_at": "2018-03-29 14:42:39 UTC",
#     "description": "email contact: contact@autonomia.digital\ntwitter: should create one",
#     "due_date": null,
#     "id": 617,
#     "iid": 1,
#     "last_edited_at": null,
#     "last_edited_by_id": null,
#     "milestone_id": null,
#     "moved_to_id": null,
#     "project_id": 15,
#     "relative_position": 1073742323,
#     "state": "closed",
#     "time_estimate": 0,
#     "title": "Add contact links",
#     "updated_at": "2018-07-20 19:33:57 UTC",
#     "updated_by_id": 10,
#     "url": "https://gitlab.autonomia.digital/infrastructure/website-autonomia.digital/issues/1",
#     "total_time_spent": 0,
#     "human_total_time_spent": null,
#     "human_time_estimate": null,
#     "assignee_ids": [
#       7
#     ],
#     "assignee_id": 7
#   },
#   "labels": [

#   ],
#   "changes": {
#     "assignees": {
#       "previous": [

#       ],
#       "current": [
#         {
#           "name": "Ola Bini",
#           "username": "ola",
#           "avatar_url": "https://gitlab.autonomia.digital/uploads/-/system/user/avatar/7/avatar.png"
#         }
#       ]
#     },
#     "total_time_spent": {
#       "previous": null,
#       "current": 0
#     }
#   },
#   "repository": {
#     "name": "website-autonomia.digital",
#     "url": "git@gitlab.autonomia.digital:infrastructure/website-autonomia.digital.git",
#     "description": "This is the repository of Centro de Autonomia Digital homepage",
#     "homepage": "https://gitlab.autonomia.digital/infrastructure/website-autonomia.digital"
#   },
#   "assignees": [
#     {
#       "name": "Ola Bini",
#       "username": "ola",
#       "avatar_url": "https://gitlab.autonomia.digital/uploads/-/system/user/avatar/7/avatar.png"
#     }
#   ]
# }
