require 'rails_helper'

module Bobot
  class Dummy
    include Bobot::Event::Common
  end
end

RSpec.describe Bobot::Dummy do
  let :payload do
    {
      'sender' => {
        'id' => '3'
      },
      'recipient' => {
        'id' => '3'
      },
      'timestamp' => 145_776_419_762_7,
      'message' => {
        'is_echo' => false,
        'mid' => 'mid.1457764197618:41d102a3e1ae206a38',
        'seq' => 73,
        'text' => 'Hello, bot!',
        'quick_reply' => {
          'payload' => 'Hi, I am a quick reply!'
        },
        'attachments' => [{
          'type' => 'image',
          'payload' => {
            'url' => 'https://www.example.com/1.jpg'
          }
        }]
      },
      'prior_message' => {
        'source' => 'checkbox_plugin',
        'identifier' => '903dac41-0976-467f-805e-ed58dc23a783'
      }
    }
  end

  let(:access_token) { 'access_token' }

  before do
    Bobot.config.pages << Bobot::Page.new(
      page_id: payload["recipient"]["id"],
      page_access_token: access_token,
    )
  end

  subject { described_class.new(payload) }

  describe '.sender' do
    it 'returns the sender' do
      expect(subject.sender).to eq(payload['sender'])
    end
  end

  describe '.recipient' do
    it 'returns the recipient' do
      expect(subject.recipient).to eq(payload['recipient'])
    end
  end

  describe '.prior_message' do
    it 'returns the message' do
      expect(subject.prior_message).to eq(payload['prior_message'])
    end
  end

  describe '.sent_at' do
    it 'returns when the message was sent' do
      expect(subject.sent_at).to eq(Time.zone.at(payload['timestamp'] / 1000))
    end
  end

  describe '.show_typing' do
    it 'sends a typing on indicator to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          sender_action: 'typing_on',
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.show_typing(state: true)
    end
    it 'sends a typing on indicator to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          sender_action: 'typing_off',
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.show_typing(state: false)
    end
  end

  describe '.mark_as_seen' do
    it 'sends a typing off indicator to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          sender_action: 'mark_seen',
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.mark_as_seen
    end
  end

  describe '.reply_with_text' do
    it 'replies to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          message: {
            text: 'Hello, human'
          },
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.reply_with_text(text: 'Hello, human')
    end
  end

  describe '.reply_with_youtube_video' do
    it 'replies to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          message: {
            attachment: {
              type: 'template',
              payload: {
                template_type: "open_graph",
                elements: [
                  { url: "https://www.youtube.com/watch?v=kJQP7kiw5Fk" }
                ],
              },
            },
          },
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.reply_with_youtube_video(url: 'https://www.youtube.com/watch?v=kJQP7kiw5Fk')
    end
  end

  describe '.reply_with_image' do
    it 'replies to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          message: {
            attachment: {
              type: 'image',
              payload: {
                url: 'https://www.foo.bar/image.jpg',
                is_reusable: true,
              },
            },
          },
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.reply_with_image(url: 'https://www.foo.bar/image.jpg')
    end
  end

  describe '.reply_with_audio' do
    it 'replies to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          message: {
            attachment: {
              type: 'audio',
              payload: {
                url: 'https://www.foo.bar/audio.mp3',
              },
            },
          },
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.reply_with_audio(url: 'https://www.foo.bar/audio.mp3')
    end
  end

  describe '.reply_with_video' do
    it 'replies to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          message: {
            attachment: {
              type: 'video',
              payload: {
                url: 'https://www.foo.bar/video.mp4',
              },
            },
          },
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.reply_with_video(url: 'https://www.foo.bar/video.mp4')
    end
  end

  describe '.reply_with_file' do
    it 'replies to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          message: {
            attachment: {
              type: 'file',
              payload: {
                url: 'https://www.foo.bar/file.zip',
              },
            },
          },
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.reply_with_file(url: 'https://www.foo.bar/file.zip')
    end
  end

  describe '.reply_with_quick_replies' do
    it 'replies to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          message: {
            text: 'Pick a color:',
            quick_replies: [
              {
                content_type: 'text',
                title: 'RED',
                payload: 'PICKED_RED_COLOR',
                image_url: 'https://foo.bar/red.png'
              },
              {
                content_type: 'text',
                title: 'GREEN',
                payload: 'PICKED_GREEN_COLOR'
              }
            ]
          },
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.reply_with_quick_replies(
        text: 'Pick a color:',
        quick_replies: [
          {
            content_type: 'text',
            title: 'RED',
            payload: 'PICKED_RED_COLOR',
            image_url: 'https://foo.bar/red.png'
          },
          {
            content_type: 'text',
            title: 'GREEN',
            payload: 'PICKED_GREEN_COLOR'
          },
        ]
      )
    end
    it 'asks the location to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          message: {
            text: 'Where are you',
            quick_replies: [
              {
                content_type: 'location',
                image_url: 'https://foo.bar/gps.png',
              }
            ]
          },
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.reply_with_quick_replies(
        text: 'Where are you',
        quick_replies: [
          Bobot::Buttons.quick_reply_location(image_url: 'https://foo.bar/gps.png')
        ]
      )
    end
  end

  describe '.reply_with_buttons' do
    it 'replies to the sender' do
      expect(subject.page).to receive(:deliver).with(
        payload_template: {
          message: {
            attachment: {
              type: 'template',
              payload: {
                template_type: 'button',
                text: 'Human, do you like me?',
                buttons: [
                  { type: 'postback', title: 'Yes', payload: 'HARMLESS' },
                  { type: 'postback', title: 'No', payload: 'WHAT_IS_A_CHATBOT' }
                ]
              }
            }
          },
          messaging_type: 'RESPONSE',
        },
        to: payload['recipient']['id'],
      )
      subject.reply_with_buttons(
        text: 'Human, do you like me?',
        buttons: [
          { type: 'postback', title: 'Yes', payload: 'HARMLESS' },
          { type: 'postback', title: 'No', payload: 'WHAT_IS_A_CHATBOT' }
        ]
      )
    end
  end
end
