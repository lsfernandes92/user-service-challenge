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

    # Why should we skip a callback validation?
    # Well, it happens that in my User model I have the following code:
    # 
    # ````
    #   before_validation :generate_key, :generate_account_key, on: :create
    # ````
    # 
    # I encountered a situation where every call to create a user factory using
    # Factory Bot triggers this unintended behavior. 
    # Additionally, the method `generate_account_key` actually call an external
    # endpoint. This, in turn, leads to a scenario where a simple
    # `GET /api/users` request inadvertently triggers the external endpoint call
    # whenever `create(:user)` is defined on tests. This is problematic because
    # `GET /api/users` shouldn't initiate external communication.
    # 
    # In order to not call this endpoint every time I mention the
    # `create(:user)` on tests, I created this trait.
    trait :without_generate_account_key_callback do
      after(:build) do |member|
        member.define_singleton_method(:generate_account_key) {}
      end
    end
  end
end
