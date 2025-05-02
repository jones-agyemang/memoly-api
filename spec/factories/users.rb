FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name { "MyString" }
    last_name { "MyString" }
  end

  trait :with_valid_auth do
    after(:create) do |user|
      create(:authentication_code, user: user)
    end
  end

  trait :with_expired_auth do
    after(:create) do |user|
      create(:authentication_code, user: user, expires_at: 2.days.ago)
    end
  end
end
