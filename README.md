<img src="https://raw.githubusercontent.com/navidemad/bobot/master/assets/images/bobot-logo.png" width="300" height="205" />
 
[![Build Status](https://travis-ci.org/navidemad/bobot.svg?branch=master)](https://travis-ci.org/navidemad/bobot) [![Gem Version](https://img.shields.io/gem/v/bobot.svg?style=flat)](https://rubygems.org/gems/bobot)
 
> Bobot is a Ruby wrapped framework to build easily a Facebook Messenger Bot.</b>

```ruby
gem 'bobot'
```

<details>
  <summary>First steps to setup</summary>
  <p>

    Run the command to install basic files: rails g bobot:install
    Then, add `bobot` section into `secrets.yml`:

    development:
      bobot:
        app_id: "123"
        app_secret: "456"
        verify_token: "your token"
        skip_code: ""
        domains: "whitelisted-domain.com,second-whitelisted-domain.com"
        async: false
        commander_queue_name: "default"
        pages: 
          - slug: "facebook_1"
            language: "fr"
            page_id: "789"
            page_access_token: "abc"
            get_started_payload: "get_started"

    Now to can edit the workflow of your bot with the file:
    - app/bobot/workflow.rb
    
  </p>
</details>

<details>
  <summary>Webhook url</summary>
  <p>

    Facebook wants an url where he can send me information to communicate with my server.
    
    When you installed Bobot, a line has been added to your config/routes.rb

    mount Bobot::Engine => "/XXXXXX", as: "bobot"
    
    You have to setup as url on the webhook facebook interface:
    - https://domain.ltd/XXXXXX/facebook
    
    And as :verify_token, the one you set on your config/secrets.yml
  </p>
</details>

<details>
  <summary>Persistent Menu, Greeting Text, Whitelist domains, Get Started</summary>
  <p>

    After having define into your `config/application.rb` your I18n.available_locales.
    
    Then, persistent menu and the greeting text will catch the content of them from `locales/bobot.{locale}.yml`
    - config/locales/bobot.{locale}.yml
    
    The whitelist domains and get_started button settings have to be set in:
    - config/secrets.yml
  </p>
</details>
  
<details>
  <summary>Find a page</summary>
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
  </p>
</details>

<details>
  <summary>Page methods: </summary>
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
  <summary>Event methods: </summary>
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

-----

> You can find more informations on the workflow : [BOBOT_WORKFLOW](BOBOT_WORKFLOW.md)

## Requirement
`ruby >= 2.3.1`

## Wiki
The [Messenger Platform - Facebook for Developers](https://developers.facebook.com/docs/messenger-platform) is available and provides full documentation for the API section.
All informations related to webhook [Messenger Platform - Webhook](https://developers.facebook.com/docs/messenger-platform/webhook-reference).

## License
The gem is available as open source under the terms of the [MIT License](MIT-LICENSE).