# Codebot

[![Gem Version](https://badge.fury.io/rb/codebot.svg)](https://rubygems.org/gems/codebot)
[![Gem Downloads](https://img.shields.io/gem/dt/codebot.svg)](https://rubygems.org/gems/codebot)
[![Build Status](https://travis-ci.org/janikrabe/codebot.svg?branch=master)](https://travis-ci.org/janikrabe/codebot)
[![Inline Docs](https://inch-ci.org/github/janikrabe/codebot.svg?branch=master)](https://inch-ci.org/github/janikrabe/codebot)

Codebot is an IRC bot that receives GitHub webhooks and forwards them to
IRC channels. It is designed to send messages in a format similar to that
of the official GitHub IRC Service. Codebot is able to stay connected after
sending messages. This eliminates the delays and visual clutter caused by
reconnecting each time a new message has to be delivered.

In addition, Codebot is able to handle many events the official service does not
support. Messages for these events are designed to be as consistent as possible
with official messages. If these additional notifications are not desired, they
can be disabled through the webhook settings.

## Features

* **Secure by default**: Codebot automatically generates strong random secrets
  for each webhook to ensure the integrity of all received data.
* **Highly configurable**: Do you use IRC over TLS or want to authenticate
  using SASL? Do you need to send notifications to a password-protected server
  or bind the IRC socket to a certain address? No problem!
* **Easy to set up**: Setting up Codebot takes three minutes — no need to edit
  configuration files or memorize complicated commands.
* **Supports many events**: Codebot supports all events supported by GitHub's
  official IRC integration, and a few more! Individual events can be enabled or
  disabled through the webhook settings.
* **Unlimited networks, channels and integrations**: a single instance can
  receive notifications for any number of webhooks and forward them to the
  appropriate channels on as many IRC networks as you want.
* **On-the-fly reloading**: A running Codebot instance can automatically pick
  up any new changes with no restart required.
  (*Changes to channel lists currently still require a restart.*)
* **Rack and Sinatra**: Thanks to Rack, Codebot can work with almost any web
  server, including the default `WEBrick` server for smaller instances.

## Installation

You can install Codebot from RubyGems by issuing the following command:

```
$ gem install codebot
```

## Usage

It only takes a few minutes to get Codebot up and running.

### Add a network

First, add the IRC networks you want to send notifications to. Remove `--secure`
if you need to connect without TLS.

```
$ codebot network create freenode --host chat.freenode.net --nick bot --secure
  Network was successfully created
  Network: freenode
      Server:     chat.freenode.net:6697 (secure connection)
      Nickname:   bot
      SASL authentication disabled
```

### Add an integration

Next, create an integration to route an endpoint to a set of IRC channels:

```
$ codebot integration create my-project -c freenode/#chan1 freenode/#chan2
  Integration was successfully created
  Integration: my-project
      Endpoint: cc5dc492-1b6a-4e13-9da9-a9cc740add1d
      Secret:   WIcSmr6bsHmv9EmaONMQ1dViu5ziKYN3gUhXoyZBh3M=
      Channels:
          - #chan1 on freenode
          - #chan2 on freenode
```

### Configure your webhook

You can now [add a GitHub webhook][newhook] to any repositories and
organizations you'd like to receive notifications from.

![Sample webhook configuration](webhook.png)

Unless configured otherwise, your **Payload URL** should be
`http://server:4567/endpoint`, where `server` is the IP address or host name of
the server Codebot is running on, and `endpoint` is the endpoint generated in
the previous step.

Both possible values for **Content type** are supported, but it is recommended
to use `application/json` instead of `application/x-www-form-encoded`.

**Secret** should be set to the secret of the integration created in the
previous step. This value is used for verifying the integrity of payloads.

You may want to choose **Let me select individual events** if you do not wish
to receive notifications for all supported events.

### Start Codebot

After adding the webhook to your GitHub repository or organization, you can
manage your Codebot instance using the following commands:

```
$ codebot core start       # Starts Codebot in the background (as a daemon)
$ codebot core stop        # Stops the active Codebot instance
$ codebot core interactive # Starts Codebot in the foreground (interactively)
```

For more information, please consult the following commands:

```
$ codebot help                      # General help
$ codebot network --help            # Commands for managing networks
$ codebot network update --help     # Possible settings for networks
$ codebot integration --help        # Commands for managing integrations
$ codebot integration update --help # Possible settings for integrations
$ codebot core --help               # Commands for managing active instances
```

The configuration is stored in `~/.codebot.yml`, but it is not recommended to
edit this file manually.

## Development

After checking out the repository, run `bundle install` to install dependencies.
You can also run `bin/console` for an interactive prompt.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[RubyGems][rubygem].

## Contributing

Bug reports and pull requests are welcome on GitHub at
[janikrabe/codebot][github].

[github]: https://github.com/janikrabe/codebot "codebot on GitHub"
[rubygem]: https://rubygems.org/gems/codebot "codebot on RubyGems.org"
[newhook]: https://developer.github.com/webhooks/creating/#setting-up-a-webhook
