FactoryBot.define do
  factory :raw_source do
    association :user

    source_type { "raw_text" }
    source { Faker::Lorem.sentence }
    status { "pending" }
  end
end
