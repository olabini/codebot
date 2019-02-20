# frozen_string_literal: true

module Codebot
  module Formatters
    module Gitlab
      # This class formats issues events.
      class IssueHook < Formatter
        # This needs a bit more work, since Gitlab issue hooks are slightly more complicated than
        # the ones for Github.


        #     if(req.body["object_attributes"]["action"] == "update") return;

        #     switch(req.body["object_attributes"]["action"].toLowerCase()) {

        #         case "open":
        #         var type = "Issue opened by ";
        #         break;

        #         case "close":
        #         var type = "Issue closed by ";
        #         break;

        #         case "reopen":
        #         var type = "Issue reopened by ";
        #         break;

        #     }

        #     var service = "Gitlab";
        #     var issue_id = req.body["object_attributes"]["iid"];
        #     var issue_title = req.body["object_attributes"]["title"];
        #     var issue_user = req.body["user"]["name"];
        #     var issue_url = req.body["object_attributes"]["url"];


        # } else if (req.headers["x-github-event"]) {

        #     switch(req.body["action"].toLowerCase()) {

        #         case "opened":
        #         var type = "Issue opened by ";
        #         break;

        #         case "closed":
        #         var type = "Issue closed by ";
        #         break;

        #         case "reopened":
        #         var type = "Issue reopened by ";
        #         break;

        #     }

        #     var service = "Github";
        #     var issue_id = req.body["issue"]["number"];
        #     var issue_title = req.body["issue"]["title"];
        #     var issue_user = req.body["issue"]["user"]["login"];
        #     var issue_url = req.body["issue"]["html_url"];

        # }

        # for (var channel of channels) {

        #     bot.say(channel, util.format("\x02\x0306Issue\x03\x02: \x02#%d\x02 \x02\x0303%s\x03\x02 - %s%s - %s",
        #         issue_id,
        #         issue_title,
        #         type,
        #         issue_user,
        #         issue_url));

        # }

        
        # Formats IRC messages for an issue event.
        #
        # @return [Array<String>] the formatted messages
        def format
          ["#{summary}: #{format_url gitlab_url}"] if gitlab_opened? || gitlab_closed?
        end

        def summary
          default_format % {
            repository: format_repository(repository_name),
            sender: format_user(extract(:user, :name)),
            action: gitlab_action,
            number: issue_number,
            title: issue_title
          }
        end

        def default_format
          '[%<repository>s] %<sender>s %<action>s issue #%<number>s: %<title>s'
        end

        def summary_url
          extract(:object_attributes, :url).to_s
        end

        def issue_number
          extract(:object_attributes, :iid)
        end

        def issue_title
          extract(:object_attributes, :title)
        end
      end
    end
  end
end
