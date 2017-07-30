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
        payload = {
          recipient: sender,
          sender_action: sender_action,
        }

        Bobot::Commander.deliver(payload, access_token: access_token)
      end

      def show_typing(state:)
        sender_action = state ? 'typing_on' : 'typing_off'

        sender_action(sender_action: sender_action)
      end

      def mark_as_seen
        sender_action(sender_action: 'mark_seen')
      end

      def reply(payload_message:)
        payload = {
          recipient: sender,
          message: payload_message,
        }

        Bobot::Commander.deliver(payload, access_token: access_token)
      end

      def reply_with_text(text:)
        payload_message = {
          text: text,
        }

        reply(payload_message: payload_message)
      end

      def reply_with_image(image_url:)
        payload_message = {
          attachment: {
            type: 'image',
            payload: {
              url: image_url,
              is_reusable: true,
            },
          },
        }

        reply(payload_message: payload_message)
      end

      def reply_with_audio(audio_url:)
        payload_message = {
          attachment: {
            type: 'audio',
            payload: {
              url: audio_url,
            },
          },
        }

        reply(payload_message: payload_message)
      end

      def reply_with_video(video_url:)
        payload_message = {
          attachment: {
            type: 'video',
            payload: {
              url: video_url,
            },
          },
        }

        reply(payload_message: payload_message)
      end

      def reply_with_file(file_url:)
        payload_message = {
          attachment: {
            type: 'file',
            payload: {
              url: file_url,
            },
          },
        }

        reply(payload_message: payload_message)
      end

      def reply_with_quick_replies(text:, quick_replies:)
        payload_message = {
          text: text,
          quick_replies: quick_replies,
        }

        reply(payload_message: payload_message)
      end

      def reply_with_buttons(payload:)
        payload_message = {
          attachment: {
            type: 'template',
            payload: payload,
          },
        }

        reply(payload_message: payload_message)
      end

      def ask_for_location(text:)
        payload_message = {
          text: text,
          quick_replies: [
            {
              content_type: 'location',
            },
          ],
        }

        reply(payload_message: payload_message)
      end

      def access_token
        Bobot.page_access_token
      end
    end
  end
end
