# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.phone_number }
    full_name { Faker::Name.name }
    password { Faker::Internet.password }
    key { Faker::Internet.password(min_length: 100, max_length: 100) }
    account_key { Faker::Internet.password(min_length: 100, max_length: 100) }
    metadata { User.generate_random_sanitized_metadata }

    trait :without_key do
      key { nil }
    end

    trait :without_account_key do
      account_key { nil }
    end
  end
end
