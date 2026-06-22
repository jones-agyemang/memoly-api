FactoryBot.define do
  factory :source_intake do
    association :user

    source_type { %w[ url ].sample }
    source { Faker::Internet.url }
  end
end
