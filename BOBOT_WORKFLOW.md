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
  Bobot::Commander.deliver(
    body: {
      recipient: {
        id: '45123'
      },
      message: {
        text: 'Human?'
      }
    },
    query: {
      access_token: "PAGE_ACCESS_TOKEN_HERE"
    }
  )
  ```

  </p>
</details>

##### Messages with image

<details>
  <summary>The human may require visual aid to understand:</summary>
  <p>

  ```ruby
  message.reply_with_image(url: 'http://sky.net/visual-aids-for-stupid-organisms/pig.jpg')
  ```

  </p>
</details>

##### Messages with audio

<details>
  <summary>The human may require audio aid to understand:</summary>
  <p>

  ```ruby
  message.reply_with_audio(url: 'http://sky.net/visual-aids-for-stupid-organisms/pig.mp3')
  ```

  </p>
</details>

##### Messages with video

<details>
  <summary>The human may require video aid to understand:</summary>
  <p>

  ```ruby
  message.reply_with_video(url: 'http://sky.net/visual-aids-for-stupid-organisms/pig.mp4')
  ```

  </p>
</details>

##### Messages with file

<details>
  <summary>The human may require video aid to understand:</summary>
  <p>

  ```ruby
  message.reply_with_file(url: 'http://sky.net/visual-aids-for-stupid-organisms/pig.zip')
  ```

  </p>
</details>

##### Messages with quick replies

<details>
  <summary>The human may appreciate hints:</summary>
  <p>

  ```ruby
  message.reply_with_quick_replies(
    text: 'Human, have you at least 18 years old?',
    quick_replies: [
      Bobot::Buttons.quick_reply_text(text: "This one", payload: "OLDER_THAN_18", image_url: nil),
      Bobot::Buttons.quick_reply_text(text: "This one", payload: "YOUNGER_THAN_18", image_url: nil),
    ]
  )
  ```

  </p>
</details>

<details>
  <summary>The human may ask the user location:</summary>
  <p>

  ```ruby
  message.reply_with_quick_replies(
    text: 'Human, have you at least 18 years old?',
    quick_replies: [
      Bobot::Buttons.quick_reply_location(image_url: nil)
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
    title: "Do you like me?"
    buttons: [
      Bobot::Buttons.postback(text: 'Yes', payload: "HARMLESS"),
      Bobot::Buttons.postback(text: 'No', payload: "WHAT_IS_A_CHATBOT"),
    ]
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

##### Messages with carousel

<details>
  <summary>The human may select between carousel items:</summary>
  <p>

  ```ruby
  message.reply_with_generic(
    image_aspect_ratio: 'square',
    elements: [
      Bobot::Buttons.generic_element(
        title: "Go to aventure",
        subtitle: "You prefer to be dressed with confortable things to move easily",
        image_url: "https://image.fr/confortable-carousel-item.jpg",
        default_action: Bobot::Buttons.default_action(
          url: "https://my.app/view?item=42",
          messenger_extensions: true,
          webview_height_ratio: "tall",
          fallback_url: "https://my.app/",
        ),
        buttons: [
          Bobot::Buttons.postback(title: 'Détente', payload: "DRESS_CONFORTABLE"),
          Bobot::Buttons.share_basic,
          Bobot::Buttons.url(title: 'see details', url: "https://my.app/view?item=42"),
          # Bobot::Buttons.call(title: 'call support', payload: "+33142324511")
        ]
      )
    ]
  )
  ```

  It is also aliased to .reply_with_carousel

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
    optin.reply_with_text(text: "Ah, human! You came from Send To Messenger plugin with ref: '#{optin.ref}'")
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
    optin.reply_with_text(text: "Ah, human! You came from m.me link with ref: '#{referral.ref}'")
  end
  ```

  </p>
</details>

#### Handle a Facebook Policy Violation

<details>
  <summary>See Facebook's documentation on [Messaging Policy Enforcement](https://developers.facebook.com/docs/messenger-platform/reference/webhook-events/messaging_policy_enforcement)</summary>
  <p>

  ```ruby
  Bobot::Commander.on :'policy-enforcement' do |referral|
    # => 'block'
    referral.action
    # => "The bot violated our Platform Policies (https://developers.facebook.com/policy/#messengerplatform). Common violations include sending out excessive spammy messages or being non-functional."
    referral.reason
  end
  ```

  </p>
</details>

[message-documentation]: https://developers.facebook.com/docs/messenger-platform/send-api-reference#request
[send-to-messenger-plugin]: https://developers.facebook.com/docs/messenger-platform/plugin-reference
