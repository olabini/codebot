

        # switch(req.body["object_attributes"]["noteable_type"].toLowerCase()) {

        #     case "commit":
        #     var type = "commit \x02\x0303" + req.body["commit"]["message"] + "\x03\x02";
        #     break;

        #     case "mergerequest":
        #     var type = "merge request \x02\x0303" + req.body["merge_request"]["title"] + "\x03\x02";
        #     break;

        #     case "issue":
        #     var type = "issue \x02\x0303" + req.body["issue"]["title"] + "\x03\x02";
        #     break;

        #     case "snippet":
        #     var type = "snippet \x02\x0303" + req.body["snippet"]["title"] + "\x03\x02";
        #     break;

        # }

        # isgd.shorten(req.body["object_attributes"]["url"], function(resp) {

        #     for (var channel of channels) {

        #         bot.say(channel, util.format("\x02\x0306Comment\x03\x02: %s commented on %s - %s",
        #             req.body["user"]["name"],
        #             type.replace(/[\r\n]/g, " - ").replace(/[\n]/g, " - "),
        #             resp));

        #     }

        # });

        # logger.info("Gitlab: " + type + " comment by " +  req.body["user"]["name"]);

