source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '7.1.3.3'
# Use Postgresql as the database
gem 'pg', '1.5.6'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'sidekiq'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '1.18.3', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# A Ruby gem offering bindings for Argon2 password hashing
gem 'argon2', '~> 2.0', '>= 2.0.3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # RSpec for Rails 6+
  gem 'rspec-rails', '~> 6.1.0'
  # Factory Bot ♥ Rails
  gem 'factory_bot_rails'
  # A library for generating fake data such as names, addresses, and phone numbers.
  gem 'faker'
end
