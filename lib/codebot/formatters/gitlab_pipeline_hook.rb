# coding: utf-8

# Triggered on status change of pipeline

module Codebot
  module Formatters
    module Gitlab
      class PipelineHook < Formatter
        def pipeline_status
          extract(:object_attributes, :status)
        end

        def format_job_status
          case self.pipeline_status
          when "created"
            "was created from commit"
          when "success"
            "succeeded"
          when "skipped"
            "was skipped"
          when /^fail/, /^err/
            "failed: #{extract(:object_attributes, :detailed_status)}"
          else
            "did something: #{self.pipeline_status}"
          end
        end

        def format
          repo_url = extract(:project, :web_url)
          repo_name = extract(:project, :path_with_namespace)

          pipeline_url = shorten_url "#{repo_url}/pipelines/#{extract(:object_attributes, :id)}"
          reply = "[%s] pipeline %s (%s)" % [
            format_repository(repo_name),
            format_job_status,
            pipeline_url,
          ]

          if self.pipeline_status == "created"
            [reply + ":"] + [format_commit(extract(:commit))]
          else
            [reply]
          end
        end
      end
    end
  end
end



# {
#   "object_kind": "pipeline",
#   "object_attributes": {
#     "id": 288,
#     "ref": "master",
#     "tag": false,
#     "sha": "93334a8bef8d5aa616c5a36043e5dacd64a39a0d",
#     "before_sha": "011dd61f7c758ea68857336af94de3a9784f16b1",
#     "status": "success",
#     "detailed_status": "passed",
#     "stages": [
#       "build",
#       "production"
#     ],
#     "created_at": "2018-11-05 13:50:03 UTC",
#     "finished_at": "2018-11-05 13:51:47 UTC",
#     "duration": 101,
#     "variables": [

#     ]
#   },
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
#     "ci_config_path": ""
#   },
#   "commit": {
#     "id": "93334a8bef8d5aa616c5a36043e5dacd64a39a0d",
#     "message": "Correctly check pushed branch(es)\n",
#     "timestamp": "2018-11-05T11:43:10Z",
#     "url": "https://gitlab.autonomia.digital/infrastructure/website-autonomia.digital/commit/93334a8bef8d5aa616c5a36043e5dacd64a39a0d",
#     "author": {
#       "name": "Varac",
#       "email": "varac@varac.net"
#     }
#   },
#   "builds": [
#     {
#       "id": 527,
#       "stage": "production",
#       "name": "production",
#       "status": "success",
#       "created_at": "2018-11-05 13:50:03 UTC",
#       "started_at": "2018-11-05 13:51:00 UTC",
#       "finished_at": "2018-11-05 13:51:47 UTC",
#       "when": "on_success",
#       "manual": false,
#       "user": {
#         "name": "Ola Bini",
#         "username": "ola",
#         "avatar_url": "https://gitlab.autonomia.digital/uploads/-/system/user/avatar/7/avatar.png"
#       },
#       "runner": null,
#       "artifacts_file": {
#         "filename": null,
#         "size": 6898
#       }
#     },
#     {
#       "id": 526,
#       "stage": "build",
#       "name": "build",
#       "status": "success",
#       "created_at": "2018-11-05 13:50:03 UTC",
#       "started_at": "2018-11-05 13:50:03 UTC",
#       "finished_at": "2018-11-05 13:50:58 UTC",
#       "when": "on_success",
#       "manual": false,
#       "user": {
#         "name": "Ola Bini",
#         "username": "ola",
#         "avatar_url": "https://gitlab.autonomia.digital/uploads/-/system/user/avatar/7/avatar.png"
#       },
#       "runner": null,
#       "artifacts_file": {
#         "filename": null,
#         "size": 6167
#       }
#     }
#   ]
# }

#----------------------------------


# {
#    "object_kind": "pipeline",
#    "object_attributes":{
#       "id": 31,
#       "ref": "master",
#       "tag": false,
#       "sha": "bcbb5ec396a2c0f828686f14fac9b80b780504f2",
#       "before_sha": "bcbb5ec396a2c0f828686f14fac9b80b780504f2",
#       "status": "success",
#       "stages":[
#          "build",
#          "test",
#          "deploy"
#       ],
#       "created_at": "2016-08-12 15:23:28 UTC",
#       "finished_at": "2016-08-12 15:26:29 UTC",
#       "duration": 63,
#       "variables": [
#         {
#           "key": "NESTOR_PROD_ENVIRONMENT",
#           "value": "us-west-1"
#         }
#       ]
#    },
#    "user":{
#       "name": "Administrator",
#       "username": "root",
#       "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon"
#    },
#    "project":{
#       "id": 1,
#       "name": "Gitlab Test",
#       "description": "Atque in sunt eos similique dolores voluptatem.",
#       "web_url": "http://192.168.64.1:3005/gitlab-org/gitlab-test",
#       "avatar_url": null,
#       "git_ssh_url": "git@192.168.64.1:gitlab-org/gitlab-test.git",
#       "git_http_url": "http://192.168.64.1:3005/gitlab-org/gitlab-test.git",
#       "namespace": "Gitlab Org",
#       "visibility_level": 20,
#       "path_with_namespace": "gitlab-org/gitlab-test",
#       "default_branch": "master"
#    },
#    "commit":{
#       "id": "bcbb5ec396a2c0f828686f14fac9b80b780504f2",
#       "message": "test\n",
#       "timestamp": "2016-08-12T17:23:21+02:00",
#       "url": "http://example.com/gitlab-org/gitlab-test/commit/bcbb5ec396a2c0f828686f14fac9b80b780504f2",
#       "author":{
#          "name": "User",
#          "email": "user@gitlab.com"
#       }
#    },
#    "builds":[
#       {
#          "id": 380,
#          "stage": "deploy",
#          "name": "production",
#          "status": "skipped",
#          "created_at": "2016-08-12 15:23:28 UTC",
#          "started_at": null,
#          "finished_at": null,
#          "when": "manual",
#          "manual": true,
#          "user":{
#             "name": "Administrator",
#             "username": "root",
#             "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon"
#          },
#          "runner": null,
#          "artifacts_file":{
#             "filename": null,
#             "size": null
#          }
#       },
#       {
#          "id": 377,
#          "stage": "test",
#          "name": "test-image",
#          "status": "success",
#          "created_at": "2016-08-12 15:23:28 UTC",
#          "started_at": "2016-08-12 15:26:12 UTC",
#          "finished_at": null,
#          "when": "on_success",
#          "manual": false,
#          "user":{
#             "name": "Administrator",
#             "username": "root",
#             "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon"
#          },
#          "runner": null,
#          "artifacts_file":{
#             "filename": null,
#             "size": null
#          }
#       },
#       {
#          "id": 378,
#          "stage": "test",
#          "name": "test-build",
#          "status": "success",
#          "created_at": "2016-08-12 15:23:28 UTC",
#          "started_at": "2016-08-12 15:26:12 UTC",
#          "finished_at": "2016-08-12 15:26:29 UTC",
#          "when": "on_success",
#          "manual": false,
#          "user":{
#             "name": "Administrator",
#             "username": "root",
#             "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon"
#          },
#          "runner": null,
#          "artifacts_file":{
#             "filename": null,
#             "size": null
#          }
#       },
#       {
#          "id": 376,
#          "stage": "build",
#          "name": "build-image",
#          "status": "success",
#          "created_at": "2016-08-12 15:23:28 UTC",
#          "started_at": "2016-08-12 15:24:56 UTC",
#          "finished_at": "2016-08-12 15:25:26 UTC",
#          "when": "on_success",
#          "manual": false,
#          "user":{
#             "name": "Administrator",
#             "username": "root",
#             "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon"
#          },
#          "runner": null,
#          "artifacts_file":{
#             "filename": null,
#             "size": null
#          }
#       },
#       {
#          "id": 379,
#          "stage": "deploy",
#          "name": "staging",
#          "status": "created",
#          "created_at": "2016-08-12 15:23:28 UTC",
#          "started_at": null,
#          "finished_at": null,
#          "when": "on_success",
#          "manual": false,
#          "user":{
#             "name": "Administrator",
#             "username": "root",
#             "avatar_url": "http://www.gravatar.com/avatar/e32bd13e2add097461cb96824b7a829c?s=80\u0026d=identicon"
#          },
#          "runner": null,
#          "artifacts_file":{
#             "filename": null,
#             "size": null
#          }
#       }
#    ]
# }
