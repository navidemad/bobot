module Bobot
  module Event
    # Common attributes for all incoming data from Facebook.
    module Common
      attr_reader :messaging, :page

      def initialize(messaging)
        @messaging = messaging
      end

      def sender
        @messaging['sender']
      end

      def recipient
        @messaging['recipient']
      end

      # If the user responds to your message, the appropriate event
      # (messages, messaging_postbacks, etc.) will be sent to your webhook,
      # with a prior_message object appended. The prior_message object
      # includes the source of the message the user is responding to, as well
      # as the user_ref used for the original message send.
      def prior_message
        @messaging['prior_message']
      end

      def sent_at
        Time.zone.at(@messaging['timestamp'] / 1000)
      end

      def sender_action(sender_action:)
        page.sender_action(sender_action: sender_action, to: sender["id"])
      end

      def show_typing(state:)
        page.show_typing(state: state, to: sender["id"])
      end

      def mark_as_seen
        page.mark_as_seen(to: sender["id"])
      end

      def reply(payload_message:)
        page.send(payload_message: payload_message, to: sender["id"])
      end

      def reply_with_text(text:)
        page.send_text(text: text, to: sender["id"])
      end

      def reply_with_attachment(url:, type:)
        page.send_attachment(url: url, type: type, to: sender["id"])
      end

      def reply_with_image(url:)
        page.send_image(url: url, to: sender["id"])
      end

      def reply_with_audio(url:)
        page.send_audio(url: url, to: sender["id"])
      end

      def reply_with_video(url:)
        page.send_video(url: url, to: sender["id"])
      end

      def reply_with_file(url:)
        page.send_file(url: url, to: sender["id"])
      end

      def reply_with_quick_replies(text:, quick_replies:)
        page.send_quick_replies(text: text, quick_replies: quick_replies, to: sender["id"])
      end

      def reply_with_buttons(text:, buttons:)
        page.send_buttons(text: text, buttons: buttons, to: sender["id"])
      end

      def reply_with_generic(elements:, image_aspect_ratio: 'square')
        page.send_generic(elements: elements, image_aspect_ratio: image_aspect_ratio, to: sender["id"])
      end
      alias_method :reply_with_carousel, :reply_with_generic

      def page
        Bobot::Page.find(recipient["id"])
      end
    end
  end
end
