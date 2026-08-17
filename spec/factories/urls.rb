FactoryBot.define do
  factory :url_source, class: 'Url' do
    association :user

    source_type { "url" }
    source { Faker::Lorem.sentence }
    status { "pending" }
  end
end
