require 'rails/generators'
require File.expand_path('../utils', __FILE__)

module Bobot
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    include Generators::Utils::InstanceMethods

    argument :_namespace, type: :string, required: false, desc: 'Bobot url namespace'
    desc 'Bobot installation generator'

    def install
      namespace = ask_for('Where do you want to mount bobot?', 'bobot', _namespace)
      route("mount Bobot::Engine => '/#{namespace}', as: 'bobot'")
      # Copy files '{TEMPLATE_FILE_PATH}', '{APP_FILE_PATH}'
      template 'config/initializers/bobot.rb', 'config/initializers/bobot.rb'
      template 'app/bobot/workflow.rb', 'app/bobot/workflow.rb'
      copy_file 'config/bobot.yml', 'config/bobot.yml'
      copy_file 'config/locales/bobot.en.yml', 'config/locales/bobot.en.yml'
      copy_file 'config/locales/bobot.fr.yml', 'config/locales/bobot.fr.yml'
    end

    # def uninstall
    #   gsub_file("config/routes.rb", "mount Bobot::Engine => '/#{_namespace}', as: 'bobot'", "")
    #   remove_file 'config/initializers/bobot.rb'
    #   remove_file 'app/models/bobot_workflow.rb'
    #   remove_file 'config/bobot.yml'
    #   remove_file 'config/locales/bobot.en.yml'
    #   remove_file 'config/locales/bobot.fr.yml'
    # end
  end
end
