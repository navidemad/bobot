module Bobot
  module Buttons
    def self.encode_payload(payload:)
      unless payload.is_a?(String)
        begin
          payload = ActiveSupport::JSON.encode(payload)
        rescue ::ActiveSupport::JSON.parse_error
          raise Bobot::FieldFormat.new('payload is not string and not a valid to be JSONified.')
        end
      end
      payload
    end

    def self.postback(title:, payload:)
      raise Bobot::FieldFormat.new('title is required.') unless title.present?
      raise Bobot::FieldFormat.new('title length is limited to 20.') if title.size > 20
      raise Bobot::FieldFormat.new('payload is required.') unless payload.present?
      payload = Bobot::Buttons.encode_payload(payload: payload)
      raise Bobot::FieldFormat.new('payload length is limited to 1000.') if payload.bytesize > 1000
      {
        type: 'postback',
        title: title,
        payload: payload,
      }
    end

    def self.generic_element(title:, subtitle: nil, image_url: nil, default_action_url: nil, buttons: nil)
      raise Bobot::FieldFormat.new('title is required.') unless title.present?
      raise Bobot::FieldFormat.new('title length is limited to 80.') if title.size > 80
      raise Bobot::FieldFormat.new('subtitle length is limited to 80.') if subtitle.present? && subtitle.size > 80
      raise Bobot::FieldFormat.new('buttons are limited to 3.') if buttons.present? && buttons.size > 3
      {
        title: title,
      }.tap do |properties|
        properties[:image_url] = image_url if image_url.present?
        properties[:subtitle] = subtitle if subtitle.present?
        properties[:default_action_url] = default_action_url if default_action_url.present?
        properties[:buttons] = buttons if buttons.present?
      end
    end
    class <<self
      alias_method :carousel_element, :generic_element
    end

    def self.quick_reply_location(image_url: nil)
      {
        content_type: 'location',
      }.tap do |properties|
        properties[:image_url] = image_url if image_url.present?
      end
    end

    def self.quick_reply_text(title:, payload:, image_url: nil)
      raise Bobot::FieldFormat.new('title is required.') unless title.present?
      raise Bobot::FieldFormat.new('title length is limited to 20.') if title.size > 20
      raise Bobot::FieldFormat.new('payload is required.') unless payload.present?
      payload = Bobot::Buttons.encode_payload(payload: payload)
      raise Bobot::FieldFormat.new('payload length is limited to 1000.') if payload.bytesize > 1000
      {
        content_type: 'text',
        title: title,
        payload: payload,
      }.tap do |properties|
        properties[:image_url] = image_url if image_url.present?
      end
    end

    def self.share_basic
      {
        type: 'element_share',
      }
    end

    def self.share_custom(title:, subtitle:, image_url:, web_url:, button_title:, image_aspect_ratio:)
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
                    url: web_url,
                  },
                  buttons: [
                    {
                      type: 'web_url',
                      url: web_url,
                      title: button_title,
                    },
                  ],
                },
              ],
            },
          },
        },
      }
    end

    def self.default_action_url(url:, options: {})
      raise Bobot::FieldFormat.new('url is required.') unless url.present?
      if options.key?(:messenger_extensions) && options[:messenger_extensions] && !url.include?('https')
        raise Bobot::FieldFormat.new('must use url HTTPS protocol if messenger_extensions is true.')
      end
      if options.key?(:webview_height_ratio) && !%w[compact tall full].include?(options[:webview_height_ratio])
        raise Bobot::FieldFormat.new('invalid webview_height_ratio, only "compact, tall, full" are permitted.')
      end
      {
        type: 'web_url',
        url: url,
      }.tap do |properties|
        properties[:webview_height_ratio] = options[:webview_height_ratio] if options.key?(:webview_height_ratio)
        properties[:messenger_extensions] = options[:messenger_extensions] if options.key?(:messenger_extensions)
        properties[:fallback_url] = options[:fallback_url] if options.key?(:fallback_url)
        properties[:webview_share_button] = options[:webview_share_button] if options.key?(:webview_share_button)
      end
    end

    def self.url(title:, url:, options: {})
      raise Bobot::FieldFormat.new('title is required.') unless title.present?
      raise Bobot::FieldFormat.new('title length is limited to 20.') if title.size > 20
      raise Bobot::FieldFormat.new('url is required.') unless url.present?
      if options.key?(:messenger_extensions) && options[:messenger_extensions] && !url.include?('https')
        raise Bobot::FieldFormat.new('must use url HTTPS protocol if messenger_extensions is true.')
      end
      if options.key?(:webview_height_ratio) && !%w[compact tall full].include?(options[:webview_height_ratio])
        raise Bobot::FieldFormat.new('invalid webview_height_ratio, only "compact, tall, full" are permitted.')
      end
      {
        type: 'web_url',
        url: url,
        title: title,
      }.tap do |properties|
        properties[:webview_height_ratio] = options[:webview_height_ratio] if options.key?(:webview_height_ratio)
        properties[:messenger_extensions] = options[:messenger_extensions] if options.key?(:messenger_extensions)
        properties[:fallback_url] = options[:fallback_url] if options.key?(:fallback_url)
        properties[:webview_share_button] = options[:webview_share_button] if options.key?(:webview_share_button)
      end
    end

    REGEX_PHONE_NUMBER = /\A(?:\+)(?:\d{1,3}\s*-?)?\(?(?:\d{3})?\)?[- ]?\d{3}[- ]?\d{4}\z/
    def self.call(title:, payload:)
      raise Bobot::FieldFormat.new('title is required.') unless title.present?
      raise Bobot::FieldFormat.new('title length is limited to 20.') if title.size > 20
      raise Bobot::FieldFormat.new('payload is required.') unless payload.present?
      raise Bobot::FieldFormat.new('payload has to be only a string') unless payload.is_a?(String)
      raise Bobot::FieldFormat.new('payload has to start with a "+" and be a valid phone number') unless REGEX_PHONE_NUMBER =~ payload
      {
        type: 'phone_number',
        title: title,
        payload: payload,
      }
    end
  end
end
