FactoryBot.define do
  factory :collection do
    association :user
    label { Faker::Space.moon }
    parent_id { "" }
    position { 1 }
  end
end
