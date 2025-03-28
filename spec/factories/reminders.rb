FactoryBot.define do
  factory :reminder do
    association :note

    due_date { "2020-06-02" }
    completed { false }
  end
end
