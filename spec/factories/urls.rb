FactoryBot.define do
  factory :url_source, class: 'Url' do
    association :user

    source_type { "url" }
    source { Faker::Internet.url }
    status { "pending" }
  end
end
