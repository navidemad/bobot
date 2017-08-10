module Bobot
  module Event
    # Common attributes for all incoming data from Facebook.
    module Common
      attr_reader :messaging
      attr_accessor :delay_options

      def initialize(messaging)
        @messaging = messaging
        @delay_options = { wait: 0, wait_until: nil }
      end

      def sender
        @messaging['sender']
      end

      def recipient
        @messaging['recipient']
      end

      def delay(wait: 0, wait_until: nil)
        raise Bobot::FieldFormat.new('wait has to be positive integer.') unless wait.present?
        if Bobot.async
          @delay_deliver[:wait] = wait if wait >= 0
          @delay_deliver[:wait_until] = wait_until if wait_until.present?
        else
          warn "delay is ignored since you configured Bobot.async to 'false'"
        end
        self
      end

      def sent_at
        Time.zone.at(@messaging['timestamp'] / 1000)
      end

      def deliver(payload_template:)
        raise Bobot::FieldFormat.new('payload_template is required.') unless payload_template.present?
        job = Bobot::CommanderJob
        if Bobot.async
          job = job.set(wait: @delay_deliver[:wait]) if @delay_deliver[:wait] > 0
          job = job.set(wait: @delay_deliver[:wait_until]) if @delay_deliver[:wait_until].present?
          job.perform_later(sender: sender, access_token: access_token, payload_template: payload_template)
        else
          job.perform_now(sender: sender, access_token: access_token, payload_template: payload_template)
        end
      end

      def sender_action(sender_action:)
        deliver(payload_template: { sender_action: sender_action })
      end

      def show_typing(state:)
        sender_action(sender_action: state ? 'typing_on' : 'typing_off')
      end

      def mark_as_seen
        sender_action(sender_action: 'mark_seen')
      end

      def reply(payload_message:)
        deliver(payload_template: { message: payload_message })
      end

      def reply_with_text(text:)
        raise Bobot::FieldFormat.new('text is required.') unless text.present?
        raise Bobot::FieldFormat.new('text length is limited to 640.') if text.size > 640
        reply(
          payload_message: {
            text: text,
          },
        )
      end

      def reply_with_attachment(url:, type:)
        raise Bobot::FieldFormat.new('url is required.') unless url.present?
        raise Bobot::FieldFormat.new('type is required.') unless type.present?
        raise Bobot::FieldFormat.new('type is invalid, only "image, audio, video, file" are permitted.') unless %w[image audio video file].include?(type)
        reply(
          payload_message: {
            attachment: {
              type: type,
              payload: {
                url: url,
              }.tap { |properties| properties.merge!(is_reusable: true) if type == 'image' },
            },
          },
        )
      end

      def reply_with_image(url:)
        reply_with_attachment(url: url, type: 'image')
      end

      def reply_with_audio(url:)
        reply_with_attachment(url: url, type: 'audio')
      end

      def reply_with_video(url:)
        reply_with_attachment(url: url, type: 'video')
      end

      def reply_with_file(url:)
        reply_with_attachment(url: url, type: 'file')
      end

      def reply_with_quick_replies(text:, quick_replies:)
        raise Bobot::FieldFormat.new('text is required.') unless text.present?
        raise Bobot::FieldFormat.new('text length is limited to 640.') if text.size > 640
        raise Bobot::FieldFormat.new('quick_replies are required.') unless quick_replies.present?
        raise Bobot::FieldFormat.new('quick_replies are limited to 11.') if quick_replies.size > 11
        reply(
          payload_message: {
            text: text,
            quick_replies: quick_replies,
          },
        )
      end

      def reply_with_buttons(text:, buttons:)
        raise Bobot::FieldFormat.new('text is required.') unless text.present?
        raise Bobot::FieldFormat.new('text length is limited to 640.') if text.size > 640
        raise Bobot::FieldFormat.new('buttons are required.') unless buttons.present?
        raise Bobot::FieldFormat.new('buttons are limited to 3.') if buttons.size > 3
        reply(
          payload_message: {
            attachment: {
              type: 'template',
              payload: {
                template_type: 'button',
                text: text,
                buttons: buttons,
              },
            },
          },
        )
      end

      def reply_with_generic(elements:, image_aspect_ratio: 'square')
        raise Bobot::FieldFormat.new('elements are required.') if elements.nil?
        raise Bobot::FieldFormat.new('elements are limited to 10.') if elements.size > 10
        raise Bobot::FieldFormat.new('image_aspect_ratio is required.') if image_aspect_ratio.nil?
        raise Bobot::FieldFormat.new('image_aspect_ratio is invalid, only "square, horizontal" are permitted.') unless %w[square horizontal].include?(image_aspect_ratio)
        reply(
          payload_message: {
            attachment: {
              type: 'template',
              payload: {
                template_type: 'generic',
                image_aspect_ratio: image_aspect_ratio,
                elements: elements,
              },
            },
          },
        )
      end
      alias_method :reply_with_carousel, :reply_with_generic

      def access_token
        Bobot.page_access_token
      end
    end
  end
end
