namespace :bobot do
  desc 'Install bobot'
  task :install do
    system 'rails g bobot:install'
  end
end
