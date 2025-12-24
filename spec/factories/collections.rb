FactoryBot.define do
  factory :collection do
    association :user
    label { Faker::Space.moon }
    parent_id { "" }
    position { 1 }
    public { false }

    trait :public_collection do
      public { true }
    end
  end
end
