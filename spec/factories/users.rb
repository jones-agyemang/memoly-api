FactoryBot.define do
  factory :user do
    email { "MyString" }
    first_name { "MyString" }
    last_name { "MyString" }
  end

  trait :with_auth_code do
    association :authentication_code
  end
end
