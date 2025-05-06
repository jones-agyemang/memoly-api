FactoryBot.define do
  factory :question do
    association :quiz

    raw_content { "What is Ruby?" }
    choices { [ "A programming language", "A gemstone", "Both" ] }
    answer { "Both" }
    explanation { "Ruby is both a programming language and the name of a gemstone" }
  end
end
