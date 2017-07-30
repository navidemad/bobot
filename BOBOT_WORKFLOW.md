<p align="center">
   <img src="https://raw.githubusercontent.com/navidemad/bobot/master/assets/images/bobot-logo.png"/>
</p>

# Bobot [![Build Status](https://travis-ci.org/navidemad/bobot.svg?branch=master)](https://travis-ci.org/navidemad/bobot) [![Gem Version](https://img.shields.io/gem/v/bobot.svg?style=flat)](https://rubygems.org/gems/bobot)
`Bobot` is a Ruby wrapped framework to build easily a Facebook Messenger Bot.

#### Sending and receiving messages

<details>
  <summary>You can reply to messages sent by the human:</summary>
  <p>

  ```ruby

  Bobot::Commander.on :message do |message|
    message.reply_with_text(text: 'Hello, human!')
  end
  ```

  </p>
</details>

<details>
  <summary>or even send the human messages out of the bot workflow scope:</summary>
  <p>

  ```ruby
  Bobot::Commander.deliver({
    recipient: {
      id: '45123'
    },
    message: {
      text: 'Human?'
    }
  }, access_token: "PAGE_ACCESS_TOKEN_HERE")
  ```

  </p>
</details>

##### Messages with images

<details>
  <summary>The human may require visual aid to understand:</summary>
  <p>

  ```ruby
  message.reply_with_image(image_url: 'http://sky.net/visual-aids-for-stupid-organisms/pig.jpg')
  ```

  </p>
</details>

##### Messages with quick replies

<details>
  <summary>The human may appreciate hints:</summary>
  <p>

  ```ruby
  message.reply_with_quick_replies(
    text: 'Human, who is your favorite bot?',
    quick_replies: [
      {
        content_type: 'text',
        title: 'You are!',
        payload: 'HARMLESS'
      }
    ]
  )
  ```

  </p>
</details>

##### Messages with buttons

<details>
  <summary>The human may require simple options to communicate:</summary>
  <p>

  ```ruby
  message.reply_with_buttons(
    payload: {
      template_type: 'button',
      text: 'Human, do you like me?',
      buttons: [
        { type: 'postback', title: 'Yes', payload: 'HARMLESS' },
        { type: 'postback', title: 'No', payload: 'WHAT_IS_A_CHATBOT' }
      ]
    }
  )
  ```

  </p>
</details>

<details>
  <summary>When the human has selected an option, you can act on it:</summary>
  <p>

  ```ruby
  Bobot::Commander.on :postback do |postback|
    if postback.payload == 'WHAT_IS_A_CHATBOT'
      puts "Human #{postback.recipient} marked for extermination"
    end
  end
  ```

  </p>
</details>

*See Facebook's [documentation][message-documentation] for all message options.*

##### Typing indicator

<details>
  <summary>Show the human you are preparing a message for them:</summary>
  <p>

  ```ruby
  Bobot::Commander.on :message do |message|
    message.show_typing(state: true)

    # Do something expensive

    message.reply_with_text(text: 'Hello, human!')
  end
  ```

  </p>
</details>

<details>
  <summary>Or that you changed your mind:</summary>
  <p>

  ```ruby
  Bobot::Commander.on :message do |message|
    message.show_typing(state: true)

    if # something
      message.reply_with_text(text: 'Hello, human!')
    else
      message.show_typing(state: off)
    end
  end
  ```

  </p>
</details>

##### Mark as viewed

<details>
  <summary>You can mark messages as seen to keep the human on their toes:</summary>
  <p>

  ```ruby
  Bobot::Commander.on :message do |message|
    message.mark_as_seen
  end
  ```

  </p>
</details>

##### Record messages

<details>
  <summary>You can keep track of messages sent to the human:</summary>
  <p>

  ```ruby
  Bobot::Commander.on :message_echo do |message_echo|
    message_echo.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
    message_echo.sender      # => { 'id' => '1008372609250235' }
    message_echo.seq         # => 73
    message_echo.sent_at     # => 2016-04-22 21:30:36 +0200
    message_echo.text        # => 'Hello, bot!'
    message_echo.attachments # => [ { 'type' => 'image', 'payload' => { 'url' => 'https://www.example.com/1.jpg' } } ]

    # Log or store in your storage method of choice (skynet, obviously)
  end
  ```

  </p>
</details>

#### Send to Facebook

<details>
  <summary>When the human clicks the [Send to Messenger button][send-to-messenger-plugin] embedded on a website, you will receive an `optin` event.</summary>
  <p>

  ```ruby
  Bobot::Commander.on :optin do |optin|
    optin.sender    # => { 'id' => '1008372609250235' }
    optin.recipient # => { 'id' => '2015573629214912' }
    optin.sent_at   # => 2016-04-22 21:30:36 +0200
    optin.ref       # => 'CONTACT_SKYNET'

    optin.reply_with_text(text: 'Ah, human!')
  end
  ```

  </p>
</details>

#### Message delivery receipts

<details>
  <summary>You can stalk the human:</summary>
  <p>

  ```ruby
  Bobot::Commander.on :delivery do |delivery|
    delivery.ids       # => 'mid.1457764197618:41d102a3e1ae206a38'
    delivery.sender    # => { 'id' => '1008372609250235' }
    delivery.recipient # => { 'id' => '2015573629214912' }
    delivery.at        # => 2016-04-22 21:30:36 +0200
    delivery.seq       # => 37

    puts "Human was online at #{delivery.at}"
  end
  ```

  </p>
</details>

#### Referral

<details>
  <summary>When the human follows a m.me link with a ref parameter like http://m.me/mybot?ref=myparam, you will receive a `referral` event.</summary>
  <p>

  ```ruby
  Bobot::Commander.on :referral do |referral|
    referral.sender    # => { 'id' => '1008372609250235' }
    referral.recipient # => { 'id' => '2015573629214912' }
    referral.sent_at   # => 2016-04-22 21:30:36 +0200
    referral.ref       # => 'MYPARAM'
  end
  ```

  </p>
</details>

[message-documentation]: https://developers.facebook.com/docs/messenger-platform/send-api-reference#request
[send-to-messenger-plugin]: https://developers.facebook.com/docs/messenger-platform/plugin-reference
