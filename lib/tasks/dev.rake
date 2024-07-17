# frozen_string_literal: true

namespace :dev do
  desc 'Seed the development environment'
  task setup: :environment do
    puts '>>> Setting up the environment...'
    `rails db:drop db:create db:migrate`
    puts '>>> Environment set up successfully!'

    puts '>>> Creating 10 new users...'
    10.times do |_|
      user_params = {
        email: Faker::Internet.email,
        phone_number: Faker::PhoneNumber.phone_number,
        full_name: Faker::Name.name,
        password: Faker::Internet.password,
        key: Faker::Internet.password(min_length: 100, max_length: 100),
        account_key: Faker::Internet.password(min_length: 100, max_length: 100),
        metadata: User.generate_random_sanitized_metadata
      }

      User.create!(user_params)
    end
    puts '>>> Users created successfully!'
  end
end
