FactoryBot.define do
  factory :collection do
    user { nil }
    label { "MyString" }
    slug { "MyString" }
    parent_id { "" }
    path { "" }
    position { 1 }
  end
end
