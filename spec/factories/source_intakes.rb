FactoryBot.define do
  factory :source_intake do
    association :user

    source_type { "url" }
    source { "https://react.dev/reference/react/useContext" }
    status { "pending" }
  end
end
