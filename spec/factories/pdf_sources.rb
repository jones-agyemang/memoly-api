FactoryBot.define do
  factory :pdf_source do
    association :user

    source_type { "pdf" }
    source { "lecture-notes.pdf" }
    status { "pending" }

    after(:build) do |source_intake|
      source_intake.document.attach(
        io: StringIO.new("%PDF-1.4\n%%EOF"),
        filename: source_intake.source,
        content_type: "application/pdf"
      )
    end
  end
end
