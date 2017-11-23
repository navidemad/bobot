module Bobot
  class Configuration
    attr_accessor :app_id, :app_secret, :verify_token, :debug_log, :async, :pages

    def domains=(rhs)
      return unless rhs.present?
      if rhs.respond_to?(:to_str)
        @domains = rhs.split(",").map(&:strip)
      elsif rhs.is_a?(Array)
        @domains = rhs
      else
        raise Bobot::InvalidParameter.new(:domains, "should be a string or an array")
      end
    end

    def find_page_by_id(page_id)
      pages.find { |page| page.page_id == page_id }
    end

    def find_page_by_slug(slug)
      pages.find { |page| page.slug == slug }
    end

    class Page
      attr_accessor :slug, :language, :page_id, :page_access_token, :get_started_payload

      def initialize(options = {})
        self.slug = options[:slug]
        self.language = options[:language]
        self.page_id = options[:page_id]
        self.page_access_token = options[:page_access_token]
        self.get_started_payload = options[:get_started_payload]
      end

      def update_facebook_setup!
        subscribe_to_facebook_page!
        set_greeting_text!
        set_whitelist_domains!
        set_get_started_button!
        set_persistent_menu!
      end

      ## == Subcribe your bot to your page ==
      def subscribe_to_facebook_page!
        raise Bobot::InvalidParameter.new(:page_id)      unless page_id.present?
        raise Bobot::InvalidParameter.new(:access_token) unless page_access_token.present?
        Bobot::Subscription.set(
          query: {
            page_id: page_id,
            access_token: page_access_token,
          },
        )
      end

      ## == Unsubcribe your bot from your page ==
      def unsubscribe_to_facebook_page!
        raise Bobot::InvalidParameter.new(:page_id)      unless page_id.present?
        raise Bobot::InvalidParameter.new(:access_token) unless page_access_token.present?
        Bobot::Subscription.unset(
          query: {
            page_id: page_id,
            access_token: page_access_token,
          },
        )
      end

      ## == Set bot description (only displayed on first time). ==
      def set_greeting_text!
        raise Bobot::InvalidParameter.new(:access_token) unless page_access_token.present?
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
          Bobot::Profile.set(
            body: { greeting: greeting_texts },
            query: { access_token: page_access_token },
          )
        else
          unset_greeting_text!
        end
      end

      def unset_greeting_text!
        raise Bobot::InvalidParameter.new(:access_token) unless page_access_token.present?
        Bobot::Profile.unset(
          body: { fields: %w[greeting] },
          query: { access_token: page_access_token },
        )
      end

      ## == Set bot whitelist domains (only displayed on first time) ==
      ## == Some features like Messenger Extensions and Checkbox Plugin require ==
      ## == a page to specify a domain whitelist. ==
      def set_whitelist_domains!
        raise Bobot::InvalidParameter.new(:access_token) unless page_access_token.present?
        raise Bobot::InvalidParameter.new(:domains) unless domains.present?
        if domains.present?
          Bobot::Profile.set(
            body: { whitelisted_domains: domains },
            query: { access_token: page_access_token },
          )
        else
          unset_whitelist_domains!
        end
      end

      def unset_whitelist_domains!
        raise Bobot::InvalidParameter.new(:access_token) unless page_access_token.present?
        raise Bobot::InvalidParameter.new(:domains) unless domains.present?
        Bobot::Profile.unset(
          body: { fields: ["whitelisted_domains"] },
          query: { access_token: page_access_token },
        )
      end

      ## == You can define the action to trigger when new humans click on ==
      ## == the Get Started button. Before doing it you should check to select the ==
      ## == messaging_postbacks field when setting up your webhook. ==
      def set_get_started_button!
        raise Bobot::InvalidParameter.new(:access_token) unless page_access_token.present?
        raise Bobot::InvalidParameter.new(:get_started_payload) unless get_started_payload.present?
        Bobot::Profile.set(
          body: { get_started: { payload: get_started_payload } },
          query: { access_token: page_access_token },
        )
      end

      def unset_get_started_button!
        raise Bobot::InvalidParameter.new(:access_token) unless page_access_token.present?
        Bobot::Profile.unset(
          body: { fields: %w[persistent_menu get_started] },
          query: { access_token: page_access_token },
        )
      end

      ## == You can show a persistent menu to humans. ==
      ## == If you want to have a persistent menu, you have to set get_started ==
      ## == button before. ==
      def set_persistent_menu!
        raise Bobot::InvalidParameter.new(:access_token) unless page_access_token.present?
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
          Bobot::Profile.set(
            body: { persistent_menu: persistent_menus },
            query: { access_token: page_access_token },
          )
        else
          unset_persistent_menu!
        end
      end

      def unset_persistent_menu!
        raise Bobot::InvalidParameter.new(:access_token) unless page_access_token.present?
        Bobot::Profile.unset(
          body: { fields: ["persistent_menu"] },
          query: { access_token: page_access_token },
        )
      end
    end
  end
end
