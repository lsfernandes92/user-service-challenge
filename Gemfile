# frozen_string_literal: true

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
# Simple, efficient background processing for Ruby
gem 'sidekiq'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '1.18.3', require: false
# A Ruby gem offering bindings for Argon2 password hashing
gem 'argon2', '~> 2.0', '>= 2.0.3'
# Simple HTTP and REST client for Ruby, inspired by microframework syntax for specifying actions.
gem 'rest-client'
# A library for generating fake data such as names, addresses, and phone numbers.
gem 'faker'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # RSpec for Rails 6+
  gem 'rspec-rails', '~> 6.1.0'
  # RuboCop is a Ruby code style checking and code formatting tool. It aims to enforce the community-driven Ruby Style Guide.
  gem 'rubocop', '~> 1.65'
end

group :test do
  # Factory Bot ♥ Rails
  gem 'factory_bot_rails'
  # Record your test suite's HTTP interactions and replay them during future test runs for fast, deterministic, accurate tests.
  gem 'vcr'
  # Library for stubbing and setting expectations on HTTP requests in Ruby.
  # Used in conjunction with the vcr gem
  gem 'webmock'
  # Strategies for cleaning databases in Ruby. Can be used to ensure a clean state for testing.
  gem 'database_cleaner-active_record'
end
