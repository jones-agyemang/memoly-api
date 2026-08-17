FactoryBot.define do
  factory :raw_text do
    association :user

    source_type { "RawText" }
    status { "pending" }
  end
end
