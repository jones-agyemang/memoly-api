FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end

  trait :with_valid_auth do
    after(:create) do |user|
      create(:authentication_code, user: user)
    end
  end

  trait :with_valid_auth_token do
    after(:create) do |user|
      create(:authentication_code, user: user)
      create(:access_token, user: user)
    end
  end

  trait :with_expired_auth do
    after(:create) do |user|
      create(:authentication_code, user: user, expires_at: 2.days.ago)
    end
  end
end
