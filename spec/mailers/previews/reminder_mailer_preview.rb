class ReminderMailerPreview < ActionMailer::Preview
  def due_notes_email
    user = User.first.id
    notes = generate_content
    ReminderMailer.with(user:, notes:).due_notes_email
  end

  private

  def generate_content
    content = []
    1.upto(5) do
      content << Faker::Lorem.paragraph(sentence_count: [ *30..45 ].sample)
    end
    content
  end
end
