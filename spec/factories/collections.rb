FactoryBot.define do
  factory :collection do
    association :user
    label { "MyString" }
    slug { "MyString" }
    parent_id { "" }
    path { "" }
    position { 1 }
  end
end
