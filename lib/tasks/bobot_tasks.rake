namespace :bobot do
  desc 'Install bobot'
  task :install do
    system 'rails g bobot:install'
  end

  desc 'Uninstall bobot'
  task :uninstall do
    system 'rails g bobot:uninstall'
  end
end
