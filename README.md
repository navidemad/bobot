<img src="https://raw.githubusercontent.com/navidemad/bobot/master/assets/images/bobot-logo.png" width="300" height="205" />
 
[![Build Status](https://travis-ci.org/navidemad/bobot.svg?branch=master)](https://travis-ci.org/navidemad/bobot) [![Gem Version](https://img.shields.io/gem/v/bobot.svg?style=flat)](https://rubygems.org/gems/bobot)
 
> Bobot is a Ruby wrapped framework to build easily a Facebook Messenger Bot.</b>

## Requirement
`ruby >= 2.3.1`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bobot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bobot
    
## Usage

### Configuration in Rails app

#### Setup app

Run the command to install basic files: 
```ruby
rails g bobot:install
```
- add config/initializers/bobot.rb
- edit config/routes.rb
- add config/locales/bobot.en.yml
- add config/locales/bobot.fr.yml
- app/bobot/workflow.rb

-----

Then, add `bobot` section into `secrets.yml`:
```yml
development:
  bobot:
    app_id: "123"
    app_secret: "456"
    verify_token: "your token"
    domains: "whitelisted-domain.com,second-whitelisted-domain.com"
    debug_log: true
    async: false
    pages: 
      - slug: "facebook_1"
        language: "fr"
        page_id: "789"
        page_access_token: "abc"
        get_started_payload: "get_started"
```

-----

From now each pages will be accessible with `Bobot.pages[:slug]`.
Now to create the workflow of your bot all the code will go into the file:
- `app/bobot/workflow.rb` [(differents workflow usages)](BOBOT_WORKFLOW.md)

#### Setup pages

You can access to page settings:
- `page = Bobot.config.find_page_by_id(facebook_page_id)`
- `page = Bobot.config.find_page_by_slug(facebook_page_slug)`

After fetching the page with command above, you have access to:
- `page.update_facebook_setup!`

Or one by one in a Rails console:
- `page.subscribe_to_facebook_page!`
- `page.unsubscribe_to_facebook_page!`
- `page.unset_greeting_text!`
- `page.set_greeting_text!`
- `page.unset_whitelist_domains!`
- `page.set_whitelist_domains!`
- `page.unset_get_started_button!`
- `page.set_get_started_button!`
- `page.unset_persistent_menu!`
- `page.set_persistent_menu!`

> Greeting Text and Persistent Menus are translated by I18n.
> You have to define into your `config/application.rb` your available_locales as I18n defined them.
> Then, Bobot when you will catch the content of them from `locales/bobot.{locale}.yml`

## Wiki
The [Messenger Platform - Facebook for Developers](https://developers.facebook.com/docs/messenger-platform) is available and provides full documentation for the API section.
All informations related to webhook [Messenger Platform - Webhook](https://developers.facebook.com/docs/messenger-platform/webhook-reference).

## License
The gem is available as open source under the terms of the [MIT License](MIT-LICENSE).