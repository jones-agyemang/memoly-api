FactoryBot.define do
  factory :authentication_code do
    code { "123456" }
    expires_at { 15.minutes.from_now }
  end
end
