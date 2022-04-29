FactoryBot.define do
  factory :user do
    sequence(:email)    { |n| "email#{n}@gmail.com" }
    sequence(:password) { |n| "password-#{n}" }
    sequence(:token)    { |n| SecureRandom.hex(User::TOKEN_HALF_LENGTH)}
    utc { rand 0..100 }

    trait :with_transactions do
      after(:create) do |user, options|
        FactoryBot.create(:transaction, user: user)
        FactoryBot.create(:transaction, user: user)
      end
    end
  end
end
