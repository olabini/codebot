# Codebot

[![Gem Version](https://badge.fury.io/rb/codebot.svg)](https://rubygems.org/gems/codebot)
[![Gem Downloads](https://img.shields.io/gem/dt/codebot.svg)](https://rubygems.org/gems/codebot)
[![Build Status](https://travis-ci.org/janikrabe/codebot.svg?branch=master)](https://travis-ci.org/janikrabe/codebot)
[![Inline Docs](http://inch-ci.org/github/janikrabe/codebot.svg?branch=master)](http://inch-ci.org/github/janikrabe/codebot)

Codebot is an IRC bot that receives GitHub webhooks and forwards them to
IRC channels. It is designed to send messages in a format identical to that
of the official GitHub IRC Service. Codebot is able to stay connected after
sending messages. This eliminates the delays and visual clutter caused by
reconnecting each time a new message needs to be delivered.

In addition, Codebot is able to handle all events not supported by the official
service. Messages for these events are designed to be as consistent as possible
with official messages. If these additional notifications are not desired, they
can be disabled through the webhook settings.

## Project Status

Codebot is currently under development and not ready for production use.

## Installation

You can install Codebot from RubyGems by issuing the following command:

```
$ gem install codebot
```

## Usage

TODO: Add instructions here

## Development

After checking out the repository, run `bundle install` to install dependencies.
You can also run `bin/console` for an interactive prompt.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[RubyGems](https://rubygems.org/gems/codebot).

## Contributing

Bug reports and pull requests are welcome on GitHub at
[janikrabe/codebot](https://github.com/janikrabe/codebot).
