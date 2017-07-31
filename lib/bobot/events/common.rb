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

      def reply_with_quick_replies(title:, quick_replies:)
        raise Bobot::FieldFormat.new('title is required.') unless title.present?
        raise Bobot::FieldFormat.new('title length is limited to 80.') if title.size > 80
        raise Bobot::FieldFormat.new('quick_replies are required.') unless quick_replies.present?
        raise Bobot::FieldFormat.new('quick_replies are limited to 11.') if quick_replies.size > 11
        reply(
          payload_message: {
            text: title,
            quick_replies: quick_replies
          },
        )
      end

      def reply_with_buttons(title:, buttons:)
        raise Bobot::FieldFormat.new('title is required.') unless title.present?
        raise Bobot::FieldFormat.new('title length is limited to 80.') if title.size > 80
        raise Bobot::FieldFormat.new('buttons are required.') unless buttons.present?
        raise Bobot::FieldFormat.new('buttons are limited to 3.') if buttons.size > 3
        reply(
          payload_message: {
            attachment: {
              type: 'template',
              payload: {
                template_type: 'button',
                text: text,
                buttons: buttons
              }
            },
          },
        )
      end

      def reply_with_generic(elements:, image_aspect_ratio: 'square')
        raise Bobot::FieldFormat.new('elements are required.') if elements.nil?
        raise Bobot::FieldFormat.new('elements are limited to 10.') if elements.size > 10
        raise Bobot::FieldFormat.new('image_aspect_ratio is required.') if image_aspect_ratio.nil?
        raise Bobot::FieldFormat.new('image_aspect_ratio is invalid, only "square, horizontal" are permitted.') unless ['square', 'horizontal'].include?(image_aspect_ratio)
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

      def access_token
        Bobot.page_access_token
      end

      def message_buttons
        @buttons ||= self.class::MessageButtons.new
      end

      class MessageButtons
        def postback(title:, payload:)
          raise Bobot::FieldFormat.new('title is required.') unless title.present?
          raise Bobot::FieldFormat.new('title length is limited to 20.') if title.size > 20
          raise Bobot::FieldFormat.new('payload is required.') unless payload.present?
          unless payload.is_a?(String)
            begin
              payload = ActiveSupport::JSON.encode(payload)
            rescue ::ActiveSupport::JSON.parse_error => e
              raise Bobot::FieldFormat.new('payload is not string and not a valid to be JSONified.')
            end
          end
          raise Bobot::FieldFormat.new('payload length is limited to 1000.') if payload.size > 20
          {
            type: 'postback',
            title: title,
            payload: payload
          }
        end

        def generic_element(title:, subtitle: nil, image_url: nil, default_action_url: nil, buttons: nil)
          raise Bobot::FieldFormat.new('title is required.') unless title.present?
          raise Bobot::FieldFormat.new('title length is limited to 80.') if title.size > 80
          raise Bobot::FieldFormat.new('subtitle length is limited to 80.') if subtitle.present? && subtitle.size > 80
          raise Bobot::FieldFormat.new('buttons are limited to 3.') if buttons.present? && buttons.size > 3
          {
            title: title,
          }.tap do |_|
            _.merge!(image_url: image_url) if image_url.present?
            _.merge!(subtitle: subtitle) if subtitle.present?
            _.merge!(default_action_url: default_action_url) if default_action_url.present?
            _.merge!(buttons: buttons) if buttons.present?
          end
        end

        def quick_reply_location(image_url: nil)
          {
            content_type: 'location',
          }.tap do |_|
            _.merge!(image_url: image_url) if image_url.present?
          end
        end

        def quick_reply_text(title:, payload:, image_url: nil)
          raise Bobot::FieldFormat.new('title is required.') unless title.present?
          raise Bobot::FieldFormat.new('title length is limited to 20.') if title.size > 20
          raise Bobot::FieldFormat.new('payload is required.') unless payload.present?
          raise Bobot::FieldFormat.new('payload length is limited to 1000.') if payload.size > 1000
          {
            content_type: 'text',
            title: title,
            payload: payload,
          }.tap do |_|
            _.merge!(image_url: image_url) if image_url.present?
          end
        end

        def share_basic(share_contents: nil)
          {
            type: 'element_share',
          }
        end

        def share_custom(title:, subtitle:, image_url:, web_url:, button_title:, image_aspect_ratio:)
          raise Bobot::FieldFormat.new('title is required.') unless title.present?
          raise Bobot::FieldFormat.new('title length is limited to 80.') if title.size > 80
          raise Bobot::FieldFormat.new('subtitle is required.') unless subtitle.present?
          raise Bobot::FieldFormat.new('subtitle length is limited to 80.') if subtitle.size > 80
          raise Bobot::FieldFormat.new('button_title is required.') unless button_title.present?
          raise Bobot::FieldFormat.new('button_title length is limited to 20.') if button_title.size > 20
          {
            type: 'element_share',
            share_contents: {
              attachment: {
                type: 'template',
                payload: {
                  template_type: 'generic',
                  image_aspect_ratio: image_aspect_ratio,
                  elements: [
                    {
                      title: title,
                      subtitle: subtitle,
                      image_url: image_url,
                      default_action: {
                        type: 'web_url',
                        url: web_url
                      },
                      buttons: [
                        {
                          type: 'web_url',
                          url: web_url,
                          title: button_title
                        }
                      ]
                    }
                  ]
                }
              }
            }
          }
        end

        def default_action_url(url:, options: {})
          raise Bobot::FieldFormat.new('url is required.') unless url.present?
          if options.has_key? :messenger_extensions && options[:messenger_extensions] && !url.include?('https')
            raise Bobot::FieldFormat.new('must use url HTTPS protocol if messenger_extensions is true.')
          end
          if options.has_key? :webview_height_ratio && !['compact', 'tall', 'full'].include?(options[:webview_height_ratio])
            raise Bobot::FieldFormat.new('invalid webview_height_ratio, only "compact, tall, full" are permitted.')
          end
          {
            type: 'web_url',
            url: url,
          }.tap do |_|
            _.merge!(webview_height_ratio: options[:webview_height_ratio] if options.has_key? :webview_height_ratio
            _.merge!(messenger_extensions: options[:messenger_extensions] if options.has_key? :messenger_extensions
            _.merge!(fallback_url: options[:fallback_url] if options.has_key? :fallback_url
            _.merge!(webview_share_button: options[:webview_share_button] if options.has_key? :webview_share_button
          end
        end

        def url(title:, url:, options: {})
          raise Bobot::FieldFormat.new('title is required.') unless title.present?
          raise Bobot::FieldFormat.new('title length is limited to 20.') if title.size > 20
          raise Bobot::FieldFormat.new('url is required.') unless url.present?
          if options.has_key? :messenger_extensions && options[:messenger_extensions] && !url.include?('https')
            raise Bobot::FieldFormat.new('must use url HTTPS protocol if messenger_extensions is true.')
          end
          if options.has_key? :webview_height_ratio && !['compact', 'tall', 'full'].include?(options[:webview_height_ratio])
            raise Bobot::FieldFormat.new('invalid webview_height_ratio, only "compact, tall, full" are permitted.')
          end
          {
            type: 'web_url',
            url: url,
            title: title,
          }.tap do |_|
            _.merge!(webview_height_ratio: options[:webview_height_ratio] if options.has_key? :webview_height_ratio
            _.merge!(messenger_extensions: options[:messenger_extensions] if options.has_key? :messenger_extensions
            _.merge!(fallback_url: options[:fallback_url] if options.has_key? :fallback_url
            _.merge!(webview_share_button: options[:webview_share_button] if options.has_key? :webview_share_button
          end
        end

        def call(title:, payload:)
          raise Bobot::FieldFormat.new('title is required.') unless title.present?
          raise Bobot::FieldFormat.new('title length is limited to 20.') if title.size > 20
          raise Bobot::FieldFormat.new('payload is required.') unless payload.present?
          raise Bobot::FieldFormat.new('payload has to start with a "+"') unless payload.starts_with?('+')
          {
            type: 'phone_number',
            title: title,
            payload: payload
          }
        end
      end
    end
  end
end
