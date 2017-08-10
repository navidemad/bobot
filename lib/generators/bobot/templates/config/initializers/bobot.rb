Bobot.configure do |config|
  config.app_id            = Rails.application.config_for(:bobot)['app_id']
  config.app_secret        = Rails.application.config_for(:bobot)['app_secret']
  config.page_access_token = Rails.application.config_for(:bobot)['page_access_token']
  config.page_id           = Rails.application.config_for(:bobot)['page_id']
  config.verify_token      = Rails.application.config_for(:bobot)['verify_token']
  config.domains           = Rails.application.config_for(:bobot)['domains'].split(',').map(&:strip)
  config.debug_log         = Rails.application.config_for(:bobot)['debug_log']
  config.async             = Rails.application.config_for(:bobot)['async']
end

unless Rails.env.production?
  bot_files = Dir[Rails.root.join('app', 'bobot', '**', '*.rb')]
  bot_reloader = ActiveSupport::FileUpdateChecker.new(bot_files) do
    bot_files.each { |file| require_dependency file }
  end

  ActiveSupport::Reloader.to_prepare do
    bot_reloader.execute_if_updated
  end

  bot_files.each { |file| require_dependency file }
end
