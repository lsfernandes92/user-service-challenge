FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.phone_number }
    full_name { Faker::Name.name }
    password { Faker::Internet.password }
    key { Faker::Internet.password(min_length: 100, max_length: 100) }
    account_key { Faker::Internet.password(min_length: 100, max_length: 100) }
    metadata { "male, age 32, unemployed, college-educated" }
  end
end
