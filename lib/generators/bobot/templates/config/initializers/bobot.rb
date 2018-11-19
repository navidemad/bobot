bobot_config = Rails.application.config_for(:bobot).with_indifferent_access
if bobot_config.present?
  Bobot.configure do |config|
    config.app_id                          = bobot_config[:app_id]
    config.app_secret                      = bobot_config[:app_secret]
    config.verify_token                    = bobot_config[:verify_token]
    config.skip_code                       = bobot_config[:skip_code]
    config.domains                         = bobot_config[:domains]
    config.async                           = bobot_config[:async]
    config.commander_queue_name            = bobot_config[:commander_queue_name]
    config.url_for_chat_extension          = bobot_config[:url_for_chat_extension]
    config.size_for_chat_extension         = bobot_config[:size_for_chat_extension]
    config.share_button_for_chat_extension = bobot_config[:share_button_for_chat_extension]
    config.in_test_for_chat_extension      = bobot_config[:in_test_for_chat_extension]
    bobot_config[:pages].each do |page|
      next if page[:slug].nil? || page[:page_id].nil? || page[:page_access_token].nil? || page[:get_started_payload].nil?

      config.pages << Bobot::Page.new(
        slug:                page[:slug],
        language:            page[:language],
        page_id:             page[:page_id],
        page_access_token:   page[:page_access_token],
        get_started_payload: page[:get_started_payload],
      )
    end
  end
  unless Rails.env.production?
    bot_files = Dir[Rails.root.join("app", "bobot", "**", "*.rb")]
    bot_reloader = ActiveSupport::FileUpdateChecker.new(bot_files) do
      bot_files.each { |file| require_dependency file }
    end
    ActiveSupport::Reloader.to_prepare do
      bot_reloader.execute_if_updated
    end
    bot_files.each { |file| require_dependency file }
  end
  if defined?(Rails::Server)
    Rails.application.config.after_initialize do
      Rails.application.config.paths.add File.join("app", "bobot"), glob: File.join("**", "*.rb")
      Rails.application.config.autoload_paths += Dir[Rails.root.join("app", "bobot", "*")]
    end
  end
end
