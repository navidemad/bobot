module Bobot
  # Defines constants and methods related to configuration
  module Configuration
    # An array of valid keys in the options hash when configuring
    VALID_CONFIGURATION_KEYS = %i[
      page_id
      app_id
      app_secret
      page_access_token
      verify_token
      domains
      debug_log
      async
    ].freeze

    # By default, don't set a facebook page id
    DEFAULT_PAGE_ID = nil

    # By default, don't set a facebook developper app id
    DEFAULT_APP_ID = nil

    # By default, don't set a facebook developper app secret
    DEFAULT_APP_SECRET = nil

    # By default, don't set a facebook developper page access token
    DEFAULT_PAGE_ACCESS_TOKEN = nil

    # By default, don't set a facebook webhook_verify_token
    DEFAULT_VERIFY_TOKEN = nil

    # By default, don't set a facebook whitelisting domains
    DEFAULT_DOMAINS = nil

    # By default, debug log is to false
    DEFAULT_DEBUG_LOG = false

    # By default, async is to false
    DEFAULT_ASYNC = false

    # @private
    attr_accessor(*VALID_CONFIGURATION_KEYS)

    # Our host application root path
    # We set this when the engine is initialized
    mattr_accessor :app_root

    # When this module is extended, set all configuration options to their default values
    def self.extended(base)
      base.reset!
    end

    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end

    # Custom self assignments
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

    # Create a hash of options and their values
    def configurations
      VALID_CONFIGURATION_KEYS.inject({}) do |option, key|
        option.merge!(key => send(key))
      end
    end

    # Reset all configuration options to defaults
    def reset!
      self.page_id = DEFAULT_PAGE_ID
      self.app_id = DEFAULT_APP_ID
      self.app_secret = DEFAULT_APP_SECRET
      self.page_access_token = DEFAULT_PAGE_ACCESS_TOKEN
      self.verify_token = DEFAULT_VERIFY_TOKEN
      self.domains = DEFAULT_DOMAINS
      self.debug_log = DEFAULT_DEBUG_LOG
      self.async = DEFAULT_ASYNC
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
      raise Bobot::InvalidParameter.new(:page_id)      unless Bobot.page_id.present?
      raise Bobot::InvalidParameter.new(:access_token) unless Bobot.page_access_token.present?
      Bobot::Subscription.set(
        query: {
          page_id: Bobot.page_id,
          access_token: Bobot.page_access_token,
        },
      )
    end

    ## == Unsubcribe your bot from your page ==
    def unsubscribe_to_facebook_page!
      raise Bobot::InvalidParameter.new(:page_id)      unless Bobot.page_id.present?
      raise Bobot::InvalidParameter.new(:access_token) unless Bobot.page_access_token.present?
      Bobot::Subscription.unset(
        query: {
          page_id: Bobot.page_id,
          access_token: Bobot.page_access_token,
        },
      )
    end

    ## == Set bot description (only displayed on first time). ==
    def set_greeting_text!
      raise Bobot::InvalidParameter.new(:access_token) unless Bobot.page_access_token.present?
      greeting_texts = []
      # Default text
      greeting_text = I18n.t('bobot.config.greeting_text', locale: I18n.default_locale, default: nil)
      if greeting_text.present?
        greeting_texts << {
          locale: 'default',
          text: greeting_text,
        }
      end
      # Each languages
      I18n.available_locales.each do |locale|
        greeting_text = I18n.t('bobot.config.greeting_text', locale: locale, default: nil)
        next unless greeting_text.present?
        facebook_locales = I18n.t('bobot.config.facebook_locales', locale: locale, default: nil)
        facebook_locales.to_a.each do |locale_long|
          greeting_texts << { locale: locale_long, text: greeting_text }
        end
      end
      if greeting_texts.present?
        Bobot::Profile.set(
          body: { greeting: greeting_texts },
          query: { access_token: Bobot.page_access_token },
        )
      else
        Bobot::Profile.unset(
          body: { fields: ["greeting"] },
          query: { access_token: Bobot.page_access_token },
        )  
      end
    end

    ## == Set bot whitelist domains (only displayed on first time) ==
    ## == Some features like Messenger Extensions and Checkbox Plugin require ==
    ## == a page to specify a domain whitelist. ==
    def set_whitelist_domains!
      raise Bobot::InvalidParameter.new(:access_token) unless Bobot.page_access_token.present?
      raise Bobot::InvalidParameter.new(:domains) unless Bobot.domains.present?
      if Bobot.domains.present?
        Bobot::Profile.set(
          body: { whitelisted_domains: Bobot.domains },
          query: { access_token: Bobot.page_access_token },
        )
      else
        Bobot::Profile.unset(
          body: { fields: ["whitelisted_domains"] },
          query: { access_token: Bobot.page_access_token },
        )  
      end
    end

    ## == You can define the action to trigger when new humans click on ==
    ## == the Get Started button. Before doing it you should check to select the ==
    ## == messaging_postbacks field when setting up your webhook. ==
    def set_get_started_button!
      raise Bobot::InvalidParameter.new(:access_token) unless Bobot.page_access_token.present?
      if I18n.exists?('bobot.config.get_started.payload')
        Bobot::Profile.set(
          body: { get_started: { payload: I18n.t('bobot.config.get_started.payload') } },
          query: { access_token: Bobot.page_access_token },
        )
      else
        Bobot::Profile.unset(
          body: { fields: ["persistent_menu", "get_started"] },
          query: { access_token: Bobot.page_access_token },
        )
      end
    end

    ## == You can show a persistent menu to humans. ==
    ## == If you want to have a persistent menu, you have to set get_started ==
    ## == button before. ==
    def set_persistent_menu!
      raise Bobot::InvalidParameter.new(:access_token) unless Bobot.page_access_token.present?
      persistent_menus = []
      # Default text
      persistent_menu = I18n.t('bobot.config.persistent_menu', locale: I18n.default_locale, default: nil)
      if persistent_menu.present?
        persistent_menus << {
          locale: 'default',
          composer_input_disabled: persistent_menu[:composer_input_disabled],
          call_to_actions: persistent_menu[:call_to_actions],
        }
      end
      # Each languages
      I18n.available_locales.each do |locale|
        persistent_menu = I18n.t('bobot.config.persistent_menu', locale: locale, default: nil)
        facebook_locales = I18n.t('bobot.config.facebook_locales', locale: locale, default: nil)
        next unless persistent_menu.present?
        facebook_locales.to_a.each do |locale_long|
          persistent_menus << {
            locale: locale_long,
            composer_input_disabled: persistent_menu[:composer_input_disabled],
            call_to_actions: persistent_menu[:call_to_actions],
          }
        end
      end
      if persistent_menus.present?
        Bobot::Profile.set(
          body: { persistent_menu: persistent_menus },
          query: { access_token: Bobot.page_access_token },
        )
      else
        Bobot::Profile.unset(
          body: { fields: ["persistent_menu"] },
          query: { access_token: Bobot.page_access_token },
        )  
      end
    end
  end
end
