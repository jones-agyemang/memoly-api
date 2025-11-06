FactoryBot.define do
  factory :note do
    association :collection

    raw_content { "MyString" }
    source { "MyString" }
  end

  trait :with_reminder_due_today do
    after(:create) do |note|
      create(:reminder, note:, due_date: Time.zone.today.beginning_of_day + 2.hours, completed: false)
    end
  end

  trait :without_due_reminders do
    after(:create) do |note|
      note.reminders.destroy_all
    end
  end
end
