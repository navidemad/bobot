require 'rails'
require 'bobot'

module Bobot
  class Engine < ::Rails::Engine
    isolate_namespace Bobot
    config.generators.api_only = true

    config.action_dispatch.rescue_responses['Bobot::ActionNotAllowed'] = :forbidden

    initializer 'bobot.load_app_root' do |app|
      Bobot.app_root = app.root
    end

    initializer 'Bobot setup middlewares' do |app|
      app.config.middleware.use ActionDispatch::Flash
    end

    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: true,
                       request_specs: true
    end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), '../tasks/*.rake')].each { |f| load f }
    end
  end
end
