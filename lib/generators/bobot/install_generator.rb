require 'pathname'
require 'rails/generators'
require File.expand_path('../utils', __FILE__)

module Bobot
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    include Generators::Utils::InstanceMethods
    extend Generators::Utils::ClassMethods
    source_root File.expand_path('../templates', __FILE__)

    argument :_namespace, type: :string, required: false, desc: 'Bobot url namespace'
    desc 'Bobot install'

    def install
      namespace = ask_for('Where do you want to mount bobot?', 'bobot', _namespace)
      create_file 'config/routes.rb'
      gsub_file 'config/routes.rb', %r{mount Bobot::Engine => \'\/.+\'(, as: \'bobot\')?}, ''
      route("mount Bobot::Engine => '/#{namespace}', as: 'bobot'")
      template 'config/initializers/bobot.rb', 'config/initializers/bobot.rb'
      template 'app/bobot/workflow.rb', 'app/bobot/workflow.rb'
      copy_file 'config/bobot.yml', 'config/bobot.yml'
      copy_file 'config/locales/bobot.en.yml', 'config/locales/bobot.en.yml'
      copy_file 'config/locales/bobot.fr.yml', 'config/locales/bobot.fr.yml'
      display 'Installation done', :green
    end
  end
end
