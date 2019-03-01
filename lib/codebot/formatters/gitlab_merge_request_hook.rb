# if (req.headers["x-gitlab-event"] != null) {

#           switch(req.body["object_attributes"]["state"].toLowerCase()) {
#               case "opened":
#               var type = "Opened";
#               break;

#               case "merged":
#               var type = "Merged";
#               break;

#               case "closed":
#               var type = "Closed";
#               break;

#               case "reopened":
#               var type = "Reopened";
#               break;
#           }

#           var action = req.body["object_attributes"]["action"];
#           var merge_url = req.body["object_attributes"]["url"];
#           var merge_id = req.body["object_attributes"]["iid"];
#           var merge_title = req.body["object_attributes"]["title"];
#           var merge_user = req.body["user"]["name"];

#       } else if (req.headers["x-github-event"]) {

#           switch(req.body["action"].toLowerCase()) {
#               case "opened":
#               var type = "Opened";
#               break;

#               case "closed":
#               var type = "Closed";
#               break;

#               case "reopened":
#               var type = "Reopened";
#               break;
#           }

#           if (req.body["pull_request"]["merged"] == true)
#               type = "Merged";

#           var action = req.body["action"];
#           var merge_url = req.body["pull_request"]["html_url"];
#           var merge_id = req.body["pull_request"]["number"];
#           var merge_title = req.body["pull_request"]["title"];
#           var merge_user = req.body["pull_request"]["user"]["login"];

#       }

#       if (action == "open" || action == "close" || action == "reopen" || action == "opened" || action == "closed" || action == "reopened" || type == "Merged") {

#           isgd.shorten(merge_url, function(resp) {

#               for (var channel of channels) {

#                   bot.say(channel, util.format("\x02\x0306Merge request\x03\x02: \x02#%d\x02 \x02\x0303%s\x03\x02 - %s by %s - %s",
#                       merge_id,
#                       merge_title,
#                       type,
#                       merge_user,
#                       resp));
#               }

#           });

#       }

#       logger.info("Merge Request");
