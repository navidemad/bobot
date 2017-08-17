bobot_config_path = Rails.root.join("config", "bobot.yml")
bobot_config = YAML.safe_load(ERB.new(File.read(bobot_config_path)).result)[Rails.env]

if bobot_config.present?
  Bobot.configure do |config|
    config.app_id            = bobot_config["app_id"]
    config.app_secret        = bobot_config["app_secret"]
    config.page_access_token = bobot_config["page_access_token"]
    config.page_id           = bobot_config["page_id"]
    config.verify_token      = bobot_config["verify_token"]
    config.domains           = bobot_config["domains"]
    config.debug_log         = bobot_config["debug_log"]
    config.async             = bobot_config["async"]
  end
else
  warn "#{bobot_config_path} not configured yet in #{Rails.env} environment."
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
