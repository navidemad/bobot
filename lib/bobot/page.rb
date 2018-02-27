module Bobot
  class Page
    attr_accessor :slug, :language, :page_id, :page_access_token, :get_started_payload

    def initialize(options = {})
      self.slug = options[:slug]
      self.language = options[:language]
      self.page_id = options[:page_id]
      self.page_access_token = options[:page_access_token]
      self.get_started_payload = options[:get_started_payload]
    end

    #####################################
    #
    #              FINDERS
    #
    #####################################

    def self.find(page_id)
      Bobot.config.pages.find { |page| page.page_id.to_s == page_id.to_s }
    end

    def self.find_by_slug(slug)
      Bobot.config.pages.find { |page| page.slug.to_s == slug.to_s }
    end

    def self.[](value)
      find(value) || find_by_slug(value)
    end

    #####################################
    #
    #              REQUESTS
    #
    #####################################

    def deliver(payload_template:, to:)
      raise Bobot::FieldFormat.new('payload_template is required') unless payload_template.present?
      Bobot::Commander.deliver(
        body: {
          recipient: { id: to },
        }.merge(payload_template),
        query: {
          access_token: page_access_token,
        },
      )
    end

    def sender_action(sender_action:, to: nil)
      deliver(payload_template: { sender_action: sender_action }, to: to)
    end

    def show_typing(state:, to: nil)
      sender_action(sender_action: (state ? 'typing_on' : 'typing_off'), to: to)
    end

    def mark_as_seen(to: nil)
      sender_action(sender_action: 'mark_seen', to: to)
    end

    def send(payload_message:, to: nil)
      deliver(payload_template: { message: payload_message }, to: to)
    end

    def send_text(text:, to: nil)
      raise Bobot::FieldFormat.new('text is required') unless text.present?
      raise Bobot::FieldFormat.new('text size is limited to 640.', "#{text} (#{text.size} chars)") if text.size > 640
      send(
        payload_message: {
          text: text,
        },
        to: to,
      )
    end

    def send_attachment(url:, type:, to: nil)
      raise Bobot::FieldFormat.new('url is required') unless url.present?
      raise Bobot::FieldFormat.new('type is required') unless type.present?
      raise Bobot::FieldFormat.new('type is invalid, only "image, audio, video, file" are permitted.', type) unless %w[image audio video file].include?(type)
      send(
        payload_message: {
          attachment: {
            type: type,
            payload: {
              url: url,
            }.tap { |properties| properties.merge!(is_reusable: true) if type == 'image' },
          },
        },
        to: to,
      )
    end

    def send_youtube_video(url:, to: nil)
      raise Bobot::FieldFormat.new('url is required') unless url.present?
      raise Bobot::FieldFormat.new('url is not valid', url) unless url =~ %r{^(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})}
      send(
        payload_message: {
          attachment: {
            type: "template",
            payload: {
              template_type: "open_graph",
              elements: [
                { url: url },
              ],
            },
          },
        },
        to: to,
      )
    end

    def send_image(url:, to: nil)
      send_attachment(url: url, type: 'image', to: to)
    end

    def send_audio(url:, to: nil)
      send_attachment(url: url, type: 'audio', to: to)
    end

    def send_video(url:, to: nil)
      send_attachment(url: url, type: 'video', to: to)
    end

    def send_file(url:, to: nil)
      send_attachment(url: url, type: 'file', to: to)
    end

    def send_quick_replies(text:, quick_replies:, to: nil)
      raise Bobot::FieldFormat.new('text is required') unless text.present?
      raise Bobot::FieldFormat.new('text size is limited to 640.', "#{text} (#{text.size} chars)") if text.size > 640
      raise Bobot::FieldFormat.new('quick_replies are required') unless quick_replies.present?
      raise Bobot::FieldFormat.new('quick_replies are limited to 11.', "#{quick_replies.size} quick replies") if quick_replies.size > 11
      send(
        payload_message: {
          text: text,
          quick_replies: quick_replies,
        },
        to: to,
      )
    end

    def send_buttons(text:, buttons:, to: nil)
      raise Bobot::FieldFormat.new('text is required') unless text.present?
      raise Bobot::FieldFormat.new('text size is limited to 640.', "#{text} (#{text.size} chars)") if text.size > 640
      raise Bobot::FieldFormat.new('buttons are required') unless buttons.present?
      raise Bobot::FieldFormat.new('buttons are limited to 3', "#{buttons.size} buttons") if buttons.size > 3
      send(
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
        to: to,
      )
    end

    def send_generic(elements:, image_aspect_ratio: 'square', to: nil)
      raise Bobot::FieldFormat.new('elements are required') if elements.nil?
      raise Bobot::FieldFormat.new('elements are limited to 10.', "#{elements.size} elements") if elements.size > 10
      raise Bobot::FieldFormat.new('image_aspect_ratio is required') if image_aspect_ratio.nil?
      raise Bobot::FieldFormat.new('image_aspect_ratio is invalid, only "square, horizontal" are permitted.', image_aspect_ratio) unless %w[square horizontal].include?(image_aspect_ratio)
      send(
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
        to: to,
      )
    end
    alias_method :send_carousel, :send_generic

    #####################################
    #
    #              SETUP
    #
    #####################################
    def update_facebook_setup!
      subscribe_to_facebook_page!
      set_greeting_text!
      set_whitelist_domains!
      set_get_started_button!
      set_persistent_menu!
    end

    ## == Subcribe your bot to your page ==
    def subscribe_to_facebook_page!
      raise Bobot::FieldFormat.new("page_id is required") unless page_id.present?
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Subscription.set(
        query: {
          page_id: page_id,
          access_token: page_access_token,
        },
      )
    end

    ## == Unsubcribe your bot from your page ==
    def unsubscribe_to_facebook_page!
      raise Bobot::FieldFormat.new("page_id is required") unless page_id.present?
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Subscription.unset(
        query: {
          page_id: page_id,
          access_token: page_access_token,
        },
      )
    end

    ## == Set bot description (only displayed on first time). ==
    def set_greeting_text!
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      greeting_texts = []
      if language.nil?
        # Default text
        greeting_text = I18n.t("bobot.#{slug}.config.greeting_text", locale: I18n.default_locale, default: nil)
        greeting_texts << { locale: 'default', text: greeting_text } if greeting_text.present?
        # Each languages
        I18n.available_locales.each do |locale|
          greeting_text = I18n.t("bobot.#{slug}.config.greeting_text", locale: locale, default: nil)
          next unless greeting_text.present?
          facebook_locales = I18n.t("bobot.#{slug}.config.facebook_locales", locale: locale, default: nil)
          facebook_locales.to_a.each do |locale_long|
            greeting_texts << { locale: locale_long, text: greeting_text }
          end
        end
      else
        greeting_text = I18n.t("bobot.#{slug}.config.greeting_text", locale: language, default: nil)
        greeting_texts << { locale: 'default', text: greeting_text } if greeting_text.present?
      end
      if greeting_texts.present?
        greeting_texts.each do |row|
          if row[:text].present? && row[:text].size > 160
            raise Bobot::FieldFormat.new("greeting text for locale #{row[:locale]} is limited to 160.", "#{row[:text]} (#{row[:text].size} chars)")
          end
        end
        Bobot::Profile.set(
          body: { greeting: greeting_texts },
          query: { access_token: page_access_token },
        )
      end
    end

    def unset_greeting_text!
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Profile.unset(
        body: { fields: %w[greeting] },
        query: { access_token: page_access_token },
      )
    end

    ## == Set bot whitelist domains (only displayed on first time) ==
    ## == Some features like Messenger Extensions and Checkbox Plugin require ==
    ## == a page to specify a domain whitelist. ==
    def set_whitelist_domains!
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      raise Bobot::FieldFormat.new("Bobot.config.domains is required") unless Bobot.config.domains.present?
      Bobot::Profile.set(
        body: { whitelisted_domains: Bobot.config.domains },
        query: { access_token: page_access_token },
      )
    end

    def unset_whitelist_domains!
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Profile.unset(
        body: { fields: ["whitelisted_domains"] },
        query: { access_token: page_access_token },
      )
    end

    ## == You can define the action to trigger when new humans click on ==
    ## == the Get Started button. Before doing it you should check to select the ==
    ## == messaging_postbacks field when setting up your webhook. ==
    def set_get_started_button!
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      raise Bobot::FieldFormat.new("get_started_payload is required") unless get_started_payload.present?
      Bobot::Profile.set(
        body: { get_started: { payload: get_started_payload } },
        query: { access_token: page_access_token },
      )
    end

    def unset_get_started_button!
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Profile.unset(
        body: { fields: %w[persistent_menu get_started] },
        query: { access_token: page_access_token },
      )
    end

    ## == You can show a persistent menu to humans. ==
    ## == If you want to have a persistent menu, you have to set get_started ==
    ## == button before. ==
    def set_persistent_menu!
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      persistent_menus = []
      # Default text
      if language.nil?
        persistent_menu = I18n.t("bobot.#{slug}.config.persistent_menu", locale: I18n.default_locale, default: nil)
        if persistent_menu.present?
          persistent_menus << {
            locale: 'default',
            composer_input_disabled: persistent_menu[:composer_input_disabled],
            call_to_actions: persistent_menu[:call_to_actions],
          }
        end
        # Each languages
        I18n.available_locales.each do |locale|
          persistent_menu = I18n.t("bobot.#{slug}.config.persistent_menu", locale: locale, default: nil)
          facebook_locales = I18n.t("bobot.#{slug}.config.facebook_locales", locale: locale, default: nil)
          next unless persistent_menu.present?
          facebook_locales.to_a.each do |locale_long|
            persistent_menus << {
              locale: locale_long,
              composer_input_disabled: persistent_menu[:composer_input_disabled],
              call_to_actions: persistent_menu[:call_to_actions],
            }
          end
        end
      else
        persistent_menu = I18n.t("bobot.#{slug}.config.persistent_menu", locale: language, default: nil)
        if persistent_menu.present?
          persistent_menus << {
            locale: 'default',
            composer_input_disabled: persistent_menu[:composer_input_disabled],
            call_to_actions: persistent_menu[:call_to_actions],
          }
        end
      end
      if persistent_menus.present?
        persistent_menus.each do |row|
          if row[:title].present? && row[:title].size > 30
            raise Bobot::FieldFormat.new("persistent menu text for locale #{row[:locale]} is limited to 30.", "#{row[:title]} (#{row[:title].size} chars)")
          end
        end
        Bobot::Profile.set(
          body: { persistent_menu: persistent_menus },
          query: { access_token: page_access_token },
        )
      end
    end

    def unset_persistent_menu!
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Profile.unset(
        body: { fields: ["persistent_menu"] },
        query: { access_token: page_access_token },
      )
    end
  end
end
