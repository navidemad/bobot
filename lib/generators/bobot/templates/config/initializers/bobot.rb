bobot_config_path = Rails.root.join("config", "secrets.yml")
bobot_config = YAML.safe_load(ERB.new(File.read(bobot_config_path)).result, [], [], true)[Rails.env]["bobot"]

if bobot_config.present?
  unless bobot_config.key?("pages")
    raise "Bobot: #{bobot_config_path} required an array key :pages (cf. https://github.com/navidemad/bobot)"
  end
  Bobot.configure do |config|
    config.app_id        = bobot_config["app_id"],
    config.app_secret    = bobot_config["app_secret"],
    config.verify_token  = bobot_config["verify_token"],
    config.domains       = bobot_config["domains"],
    config.debug_log     = bobot_config["debug_log"],
    config.async         = bobot_config["async"],
    bobot_config["pages"].each do |page|
      config.pages << Bobot::Page.new(
        slug:                page["slug"],
        language:            page["language"],
        page_id:             page["page_id"],
        page_access_token:   page["page_access_token"],
        get_started_payload: page["get_started_payload"],
      )
    end
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

if defined?(Rails::Server)
  Rails.application.config.after_initialize do
    Rails.application.config.paths.add File.join("app", "bobot"), glob: File.join("**", "*.rb")
    Rails.application.config.autoload_paths += Dir[Rails.root.join("app", "bobot", "*")]
  end
end
