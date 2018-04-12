require 'rails/generators'
require File.expand_path('utils', __dir__)

module Bobot
  class UninstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    include Generators::Utils::InstanceMethods
    extend Generators::Utils::ClassMethods
    source_root File.expand_path('templates', __dir__)

    desc 'Bobot uninstall'

    def uninstall
      display 'Why you leaving so soon? :('
      gsub_file 'config/routes.rb', %r{mount Bobot::Engine => \'\/.+\'(, as: \'bot\')?}, ''
      remove_file 'config/initializers/bobot.rb'
      remove_file 'app/bobot/workflow.rb'
      remove_file 'config/locales/bobot.en.yml'
      remove_file 'config/locales/bobot.fr.yml'
      display 'Done! Bobot has been uninstalled.'
    end
  end
end
