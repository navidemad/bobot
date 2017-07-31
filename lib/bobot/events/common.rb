module Bobot
  module Event
    # Common attributes for all incoming data from Facebook.
    module Common
      attr_reader :messaging

      def initialize(messaging)
        @messaging = messaging
      end

      def sender
        @messaging['sender']
      end

      def recipient
        @messaging['recipient']
      end

      def sent_at
        Time.zone.at(@messaging['timestamp'] / 1000)
      end

      def sender_action(sender_action:)
        Bobot::Commander.deliver(
          body: {
            recipient: sender,
            sender_action: sender_action,
          },
          query: {
            access_token: access_token,
          },
        )
      end

      def show_typing(state:)
        sender_action(sender_action: state ? 'typing_on' : 'typing_off')
      end

      def mark_as_seen
        sender_action(sender_action: 'mark_seen')
      end

      def reply(payload_message:)
        Bobot::Commander.deliver(
          body: {
            recipient: sender,
            message: payload_message,
          },
          query: {
            access_token: access_token,
          },
        )
      end

      def reply_with_text(text:)
        reply(
          payload_message: {
            text: text,
          },
        )
      end

      def reply_with_image(image_url:)
        reply(
          payload_message: {
            attachment: {
              type: 'image',
              payload: {
                url: image_url,
                is_reusable: true,
              },
            },
          },
        )
      end

      def reply_with_audio(audio_url:)
        reply(
          payload_message: {
            attachment: {
              type: 'audio',
              payload: {
                url: audio_url,
              },
            },
          },
        )
      end

      def reply_with_video(video_url:)
        reply(
          payload_message: {
            attachment: {
              type: 'video',
              payload: {
                url: video_url,
              },
            },
          },
        )
      end

      def reply_with_file(file_url:)
        reply(
          payload_message: {
            attachment: {
              type: 'file',
              payload: {
                url: file_url,
              },
            },
          },
        )
      end

      def reply_with_quick_replies(text:, quick_replies:)
        reply(
          payload_message: {
            text: text,
            quick_replies: quick_replies,
          },
        )
      end

      def reply_with_buttons(payload:)
        reply(
          payload_message: {
            attachment: {
              type: 'template',
              payload: payload,
            },
          },
        )
      end

      def ask_for_location(text:)
        reply(
          payload_message: {
            text: text,
            quick_replies: [
              {
                content_type: 'location',
              },
            ],
          },
        )
      end

      def access_token
        Bobot.page_access_token
      end
    end
  end
end
