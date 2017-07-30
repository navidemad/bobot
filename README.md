<p align="center">
   <img src="https://raw.githubusercontent.com/navidemad/bobot/master/assets/images/bobot-logo.png"/>
</p>

# Bobot [Gem under development !][![Build Status](https://travis-ci.org/navidemad/bobot.svg?branch=master)](https://travis-ci.org/navidemad/bobot) [![Gem Version](https://img.shields.io/gem/v/bobot.svg?style=flat)](https://rubygems.org/gems/bobot)
`Bobot` is a Ruby wrapped framework to build easily a Facebook Messenger Bot.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'bobot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bobot

## Requirement
`bobot` has only requirement to have at least `ruby 2.3.1`.

## Setup

Typing the following command in your Rails application will add the bot to your app.
`rails g bobot:install`

`config/bobot.yml` contains your bot keys
`app/bobot/workflow.rb` contains the workflow of your bot

You can run in a Rails console:
`Bobot.update_facebook_setup!`

Or one by one in a Rails console:
`Bobot.subscribe_to_facebook_page!`
`Bobot.unsubscribe_to_facebook_page!`
`Bobot.set_greeting_text!`
`Bobot.set_whitelist_domains!`
`Bobot.set_get_started_button!`
`Bobot.set_persistent_menu!`

Greeting Text and Persistent Menus are translated by I18n.
You have to define into your `config/application.rb` your available_locales as I18n defined them.
Then, Bobot when you will catch the content of them from `locales/bobot.{locale}.yml`

## Usage
See example [Workflow](BOBOT_WORKFLOW.md)
## Wiki
The [Messenger Platform - Facebook for Developers](https://developers.facebook.com/docs/messenger-platform) is available and provides full documentation for the API section.
All informations related to webhook [Messenger Platform - Webhook](https://developers.facebook.com/docs/messenger-platform/webhook-reference).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/navidemad/bobot.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](MIT-LICENSE).

## Code of Conduct
Everyone interacting in the Bobot project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/navidemad/bobot/blob/master/CODE_OF_CONDUCT.md).

## Contributing
Please refer to [CONTRIBUTING.md](CONTRIBUTING.md).
