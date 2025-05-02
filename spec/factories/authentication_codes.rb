FactoryBot.define do
  factory :authentication_code do
    association :user

    code { 123456 }
    expires_at { "2025-05-02 16:34:05" }
  end
end
