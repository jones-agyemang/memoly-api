FactoryBot.define do
  factory :url_source, class: 'Url' do
    association :user

    source_type { "url" }
    source { "https://www.example.com" }
    status { "pending" }
  end
end
