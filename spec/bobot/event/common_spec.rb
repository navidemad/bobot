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
      }
    }
  end

  let(:access_token) { 'access_token' }

  before do
    Bobot.page_access_token = access_token
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

  describe '.sent_at' do
    it 'returns when the message was sent' do
      expect(subject.sent_at).to eq(Time.zone.at(payload['timestamp'] / 1000))
    end
  end

  describe '.show_typing' do
    it 'sends a typing on indicator to the sender' do
      expect(Bobot::Commander).to receive(:deliver)
        .with({
                recipient: subject.sender,
                sender_action: 'typing_on'
              }, access_token: access_token)

      subject.show_typing(state: true)
    end
    it 'sends a typing on indicator to the sender' do
      expect(Bobot::Commander).to receive(:deliver)
        .with({
                recipient: subject.sender,
                sender_action: 'typing_off'
              }, access_token: access_token)

      subject.show_typing(state: false)
    end
  end

  describe '.mark_as_seen' do
    it 'sends a typing off indicator to the sender' do
      expect(Bobot::Commander).to receive(:deliver)
        .with({
                recipient: subject.sender,
                sender_action: 'mark_seen'
              }, access_token: access_token)

      subject.mark_as_seen
    end
  end

  describe '.reply_with_text' do
    it 'replies to the sender' do
      expect(Bobot::Commander).to receive(:deliver)
        .with({
                recipient: subject.sender,
                message: {
                  text: 'Hello, human'
                }
              }, access_token: access_token)

      subject.reply_with_text(text: 'Hello, human')
    end
  end

  describe '.reply_with_image' do
    it 'replies to the sender' do
      expect(Bobot::Commander).to receive(:deliver)
        .with({
                recipient: subject.sender,
                message: {
                  attachment: {
                    type: 'image',
                    payload: {
                      url: 'https://www.foo.bar/image.jpg',
                      is_reusable: true,
                    },
                  },
                },
              }, access_token: access_token)

      subject.reply_with_image(image_url: 'https://www.foo.bar/image.jpg')
    end
  end

  describe '.reply_with_audio' do
    it 'replies to the sender' do
      expect(Bobot::Commander).to receive(:deliver)
        .with({
                recipient: subject.sender,
                message: {
                  attachment: {
                    type: 'audio',
                    payload: {
                      url: 'https://www.foo.bar/audio.mp3'
                    }
                  }
                }
              }, access_token: access_token)

      subject.reply_with_audio(audio_url: 'https://www.foo.bar/audio.mp3')
    end
  end

  describe '.reply_with_video' do
    it 'replies to the sender' do
      expect(Bobot::Commander).to receive(:deliver)
        .with({
                recipient: subject.sender,
                message: {
                  attachment: {
                    type: 'video',
                    payload: {
                      url: 'https://www.foo.bar/video.mp4'
                    }
                  }
                }
              }, access_token: access_token)

      subject.reply_with_video(video_url: 'https://www.foo.bar/video.mp4')
    end
  end

  describe '.reply_with_file' do
    it 'replies to the sender' do
      expect(Bobot::Commander).to receive(:deliver)
        .with({
                recipient: subject.sender,
                message: {
                  attachment: {
                    type: 'file',
                    payload: {
                      url: 'https://www.foo.bar/file.zip'
                    }
                  }
                }
              }, access_token: access_token)

      subject.reply_with_file(file_url: 'https://www.foo.bar/file.zip')
    end
  end

  describe '.quick_replies' do
    it 'replies to the sender' do
      expect(Bobot::Commander).to receive(:deliver)
        .with({
                recipient: subject.sender,
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
                }
              }, access_token: access_token)

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
  end

  describe '.reply_with_buttons' do
    it 'replies to the sender' do
      expect(Bobot::Commander).to receive(:deliver)
        .with({
                recipient: subject.sender,
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
                }
              }, access_token: access_token)

      subject.reply_with_buttons(
        payload: {
          template_type: 'button',
          text: 'Human, do you like me?',
          buttons: [
            { type: 'postback', title: 'Yes', payload: 'HARMLESS' },
            { type: 'postback', title: 'No', payload: 'WHAT_IS_A_CHATBOT' }
          ]
        }
      )
    end
  end

  describe '.ask_for_location' do
    it 'asks the location to the sender' do
      expect(Bobot::Commander).to receive(:deliver)
        .with({
                recipient: subject.sender,
                message: {
                  text: 'Where are you',
                  quick_replies: [
                    {
                      content_type: 'location'
                    }
                  ]
                }
              }, access_token: access_token)

      subject.ask_for_location(text: 'Where are you')
    end
  end
end
