source 'https://rubygems.org'

gemspec

group :active_record do
  gem 'mysql2', platforms: [:ruby, :mswin, :mingw]
end

group :development, :test do
  gem 'byebug'
end

group :test do
  gem 'generator_spec'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'simplecov', require: false
  gem 'webmock'
end
