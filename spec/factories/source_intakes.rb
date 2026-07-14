FactoryBot.define do
  factory :source_intake do
    association :user

    source_type { %w[ url ].sample }
    source { "https://react.dev/reference/react/useContext" }
    status { "pending" }
  end
end
