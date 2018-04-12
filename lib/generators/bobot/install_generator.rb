require 'pathname'
require 'rails/generators'
require File.expand_path('utils', __dir__)

module Bobot
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    include Generators::Utils::InstanceMethods
    extend Generators::Utils::ClassMethods
    source_root File.expand_path('templates', __dir__)

    argument :_namespace, type: :string, required: false, desc: 'Bot url namespace'
    desc 'Bobot install'

    def install
      remove_file 'config/initializers/bobot.rb'
      namespace = ask_for('Where do you want to mount bobot?', 'bot', _namespace)
      route("mount Bobot::Engine => '/#{namespace}', as: 'bot'")
      template 'config/initializers/bobot.rb', 'config/initializers/bobot.rb'
      template 'app/bobot/workflow.rb', 'app/bobot/workflow.rb'
      copy_file 'config/locales/bobot.en.yml', 'config/locales/bobot.en.yml'
      copy_file 'config/locales/bobot.fr.yml', 'config/locales/bobot.fr.yml'
      display 'Installation done', :green
    end
  end
end
