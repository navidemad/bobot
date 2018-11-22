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
      if payload_template.present?
        if payload_template.key?(:messaging_options) && !payload_template[:messaging_options].nil? && payload_template[:messaging_options].key?(:messaging_type)
          if !%w[RESPONSE UPDATE MESSAGE_TAG].include?(payload_template[:messaging_options][:messaging_type])
            raise Bobot::FieldFormat.new('payload_template[:messaging_options][:messaging_type] is invalid, only "RESPONSE, UPDATE, MESSAGE_TAG" are permitted.', payload_template[:messaging_options][:messaging_type])
          elsif "MESSAGE_TAG" == payload_template[:messaging_options][:messaging_type] && !payload_template[:messaging_options].key?(:tag)
            raise Bobot::FieldFormat.new('payload_template[:messaging_options][:key] is required when messaging_type is MESSAGE_TAG.', payload_template[:messaging_options][:tag])
          end
        end
      else
        raise Bobot::FieldFormat.new('payload_template is required')
      end
      body = { recipient: { id: to }, messaging_type: "RESPONSE" }.merge(payload_template).merge(payload_template[:messaging_options] || {})
      query = { access_token: page_access_token }
      Bobot::Commander.deliver(
        body: body,
        query: query,
      )
    end
    
    def sender_action(sender_action:, to: nil, messaging_options: nil)
      deliver(payload_template: { sender_action: sender_action, messaging_options: messaging_options }, to: to)
    end

    def show_typing(state:, to: nil, messaging_options: nil)
      sender_action(sender_action: (state ? 'typing_on' : 'typing_off'), messaging_options: messaging_options, to: to)
    end

    def mark_as_seen(to: nil, messaging_options: nil)
      sender_action(sender_action: 'mark_seen', messaging_options: messaging_options, to: to)
    end

    def send(payload_message:, to: nil, messaging_options: nil)
      deliver(payload_template: { message: payload_message, messaging_options: messaging_options }, to: to)
    end

    def send_text(text:, to: nil, messaging_options: nil)
      raise Bobot::FieldFormat.new('text is required') unless text.present?
      raise Bobot::FieldFormat.new('text size is limited to 640.', "#{text} (#{text.size} chars)") if text.size > 640
      send(
        payload_message: {
          text: text,
        },
        to: to,
        messaging_options: messaging_options,
      )
    end

    def send_attachment(url:, type:, to: nil, messaging_options: nil)
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
        messaging_options: messaging_options,
      )
    end

    def send_youtube_video(url:, to: nil, messaging_options: nil)
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
        messaging_options: messaging_options,
      )
    end

    def send_image(url:, to: nil, messaging_options: nil)
      send_attachment(url: url, type: 'image', to: to, messaging_options: messaging_options)
    end

    def send_audio(url:, to: nil, messaging_options: nil)
      send_attachment(url: url, type: 'audio', to: to, messaging_options: messaging_options)
    end

    def send_video(url:, to: nil, messaging_options: nil)
      send_attachment(url: url, type: 'video', to: to, messaging_options: messaging_options)
    end

    def send_file(url:, to: nil, messaging_options: nil)
      send_attachment(url: url, type: 'file', to: to, messaging_options: messaging_options)
    end

    def send_quick_replies(text:, quick_replies:, to: nil, messaging_options: nil)
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
        messaging_options: messaging_options,
      )
    end

    def send_buttons(text:, buttons:, to: nil, messaging_options: nil)
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
        messaging_options: messaging_options,
      )
    end

    def send_generic(elements:, image_aspect_ratio: 'square', to: nil, messaging_options: nil)
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
        messaging_options: messaging_options,
      )
    end
    alias_method :send_carousel, :send_generic

    #####################################
    #
    #              SETUP
    #
    #####################################
    def update_facebook_setup!
      begin
        puts "- unset_whitelist_domains! [....]"
        unset_whitelist_domains!
        puts "- unset_whitelist_domains! [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      begin
        puts "- set_whitelist_domains! [....]"
        set_whitelist_domains!
        puts "- set_whitelist_domains! [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      begin
        puts "- unset_greeting_text! [....]"
        unset_greeting_text!
        puts "- unset_greeting_text! [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      begin
        puts "- set_greeting_text! [....]"
        set_greeting_text!
        puts "- set_greeting_text! [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      begin
        puts "- unset_get_started_button! [....]"
        unset_get_started_button!
        puts "- unset_get_started_button! [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      begin
        puts "- set_get_started_button! [....]"
        set_get_started_button!
        puts "- set_get_started_button! [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      begin
        puts "- unset_persistent_menu! [....]"
        unset_persistent_menu!
        puts "- unset_persistent_menu! [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      begin
        puts "- set_persistent_menu! [....]"
        set_persistent_menu!
        puts "- set_persistent_menu! [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      if Bobot.config.url_for_chat_extension.present?
        begin
          puts "- unset_messenger_extensions_home_url! [....]"
          unset_messenger_extensions_home_url!
          puts "- unset_messenger_extensions_home_url! [DONE]"
        rescue => e
          Rails.logger.error(e.message)
        end
        begin
          puts "- set_messenger_extensions_home_url! [....]"
          set_messenger_extensions_home_url!
          puts "- set_messenger_extensions_home_url! [DONE]"
        rescue => e
          Rails.logger.error(e.message)
        end
      end
    end

    def get_facebook_setup
      begin
        puts "- get_whitelist_domains [....]"
        puts get_whitelist_domains.inspect
        puts "- get_whitelist_domains [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      begin
        puts "- get_greeting_text [....]"
        puts get_greeting_text.inspect
        puts "- get_greeting_text [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      begin
        puts "- get_started_button [....]"
        puts get_started_button.inspect
        puts "- get_started_button [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      begin
        puts "- get_persistent_menu [....]"
        puts get_persistent_menu.inspect
        puts "- get_persistent_menu [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
      begin
        puts "- get_messenger_extensions_home_url [....]"
        puts get_messenger_extensions_home_url.inspect
        puts "- get_messenger_extensions_home_url [DONE]"
      rescue => e
        Rails.logger.error(e.message)
      end
    end

    ## == Set bot description (only displayed on first time). ==
    def set_greeting_text!
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      greeting_texts = []
      if self.language.nil?
        # Default text
        short_slug = slug.gsub(/_\w+$/, "")
        greeting_text = I18n.t("bobot.#{slug}.config.greeting_text", locale: I18n.default_locale, default: nil)
        greeting_text = I18n.t("bobot.#{short_slug}.config.greeting_text", locale: I18n.default_locale, default: nil) if greeting_text.nil?
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
        short_slug = slug.gsub(/_#{language}$/, "")
        greeting_text = I18n.t("bobot.#{slug}.config.greeting_text", locale: language, default: nil)
        greeting_text = I18n.t("bobot.#{short_slug}.config.greeting_text", locale: language, default: nil) if greeting_text.nil?
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

    def get_greeting_text
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Profile.get(
        query: { access_token: page_access_token, fields: %w[greeting] },
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
        body: { fields: %w[whitelisted_domains] },
        query: { access_token: page_access_token },
      )
    end

    def get_whitelist_domains
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Profile.get(
        query: { access_token: page_access_token, fields: %w[whitelisted_domains] },
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
    
    def get_started_button
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Profile.get(
        query: { access_token: page_access_token, fields: %w[get_started] },
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
        short_slug = slug.gsub(/_\w+$/, "")
        persistent_menu = I18n.t("bobot.#{slug}.config.persistent_menu", locale: I18n.default_locale, default: nil)
        persistent_menu = I18n.t("bobot.#{short_slug}.config.persistent_menu", locale: I18n.default_locale, default: nil) if persistent_menu.nil?
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
          persistent_menu = I18n.t("bobot.#{short_slug}.config.persistent_menu", locale: locale, default: nil) if persistent_menu.nil?
          facebook_locales = I18n.t("bobot.#{slug}.config.facebook_locales", locale: locale, default: nil)
          facebook_locales = I18n.t("bobot.#{short_slug}.config.facebook_locales", locale: locale, default: nil) if facebook_locales.nil?
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
        short_slug = slug.gsub(/_#{language}$/, "")
        persistent_menu = I18n.t("bobot.#{slug}.config.persistent_menu", locale: language, default: nil)
        persistent_menu = I18n.t("bobot.#{short_slug}.config.persistent_menu", locale: language, default: nil) if persistent_menu.nil?
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
        body: { fields: %w[persistent_menu] },
        query: { access_token: page_access_token },
      )
    end

    def get_persistent_menu
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Profile.get(
        query: { access_token: page_access_token, fields: %w[persistent_menu] },
      )
    end

    ## == Set bot home url ==
    ## == Allows your bot to enable a Chat Extension in the composer drawer in Messenger. ==
    ## == It controls what is displayed when the Chat Extension is invoked via the composer drawer in Messenger. ==
    def set_messenger_extensions_home_url!
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      raise Bobot::FieldFormat.new("Bobot.config.url_for_chat_extension is required") unless Bobot.config.url_for_chat_extension.present?
      Bobot::Profile.set(
        body: { 
          "home_url": {
            "url": Bobot.config.url_for_chat_extension,
            "webview_height_ratio": Bobot.config.size_for_chat_extension || "tall",
            "webview_share_button": Bobot.config.share_button_for_chat_extension || "show",
            "in_test": Bobot.config.in_test_for_chat_extension || true,
          }
        },
        query: { access_token: page_access_token },
      )
    end

    def unset_messenger_extensions_home_url!
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Profile.unset(
        body: { fields: %w[home_url] },
        query: { access_token: page_access_token },
      )
    end

    def get_messenger_extensions_home_url
      raise Bobot::FieldFormat.new("access_token is required") unless page_access_token.present?
      Bobot::Profile.get(
        query: { access_token: page_access_token, fields: %w[home_url] },
      )
    end
  end
end
