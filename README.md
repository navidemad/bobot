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

<details>
  <summary>Configuration in Rails app</summary>
  <p>

    Run the command to install basic files: rails g bobot:install
    Then, add `bobot` section into `secrets.yml`:

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

    -----

    Now to create the workflow of your bot all the code will go into the file:
    - app/bobot/workflow.rb
    
  </p>
</details>

<details>
  <summary>Configuration Facebook Webhook</summary>
  <p>
    Bobot has a WebhookController mount depending on your routes.
    You have to setup as url on the webhook facebook interface:
    - https://domain.ltd/{:as}/facebook
  </p>
</details>

<details>
  <summary>Configuration Facebook Page (persistent_menu, greeting_text, domains, get_started)</summary>
  <p>

    You can access to page settings:
    - `page = Bobot::Page.find(facebook_page_id)`
    - `page = Bobot::Page.find_by_slug(facebook_page_slug)`
    - `page = Bobot::Page[facebook_page_id]`
    - `page = Bobot::Page[facebook_page_slug]`

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
    
    Greeting Text and Persistent Menus are translated by I18n.
    You have to define into your `config/application.rb` your available_locales as I18n defined them.
    Then, Bobot when you will catch the content of them from `locales/bobot.{locale}.yml`

  </p>
</details>

<details>
  <summary>Page can send messages with the following commands: </summary>
  <p>
    The parameter :to is the facebook uid of the target.

    - page.sender_action(sender_action:, to: nil)
    - page.show_typing(state:, to: nil)
    - page.mark_as_seen(to: nil)
    - page.send(payload_message:, to: nil)
    - page.send_text(text:, to: nil)
    - page.send_attachment(url:, type:, to: nil)
    - page.send_image(url:, to: nil)
    - page.send_audio(url:, to: nil)
    - page.send_video(url:, to: nil)
    - page.send_file(url:, to: nil)
    - page.send_quick_replies(text:, quick_replies:, to: nil)
    - page.send_buttons(text:, buttons:, to: nil)
    - page.send_generic(elements:, image_aspect_ratio: 'square', to: nil)
    - page.send_carousel(elements:, image_aspect_ratio: 'square', to: nil)
  </p>
</details>

<details>
  <summary>Event can send messages too but forward to page commands: </summary>
  <p>
    The event is the parameter that you receive in your block when you are hooking an event on your workflow.rb

    - event.sender_action(sender_action:)
    - event.show_typing(state:)
    - event.mark_as_seen
    - event.reply(payload_message:)
    - event.reply_with_text(text:)
    - event.reply_with_attachment(url:, type:)
    - event.reply_with_image(url:)
    - event.reply_with_audio(url:)
    - event.reply_with_video(url:)
    - event.reply_with_file(url:)
    - event.reply_with_quick_replies(text:, quick_replies:)
    - event.reply_with_buttons(text:, buttons:)
    - event.reply_with_generic(elements:, image_aspect_ratio: 'square')
    - event.reply_with_carousel(elements:, image_aspect_ratio: 'square')
  </p>
</details>

## Wiki
The [Messenger Platform - Facebook for Developers](https://developers.facebook.com/docs/messenger-platform) is available and provides full documentation for the API section.
All informations related to webhook [Messenger Platform - Webhook](https://developers.facebook.com/docs/messenger-platform/webhook-reference).

## License
The gem is available as open source under the terms of the [MIT License](MIT-LICENSE).