class ReminderMailerPreview < ActionMailer::Preview
  def due_notes_email
    user = User.first.id
    notes = generate_content
    ReminderMailer.with(user:, notes:).due_notes_email
  end

  private

  def generate_content
    content = []
    content << "$$\int_a^x f(t)\,dt = F(x) - F(a)$$"
    1.upto(5) do
      content << Faker::Lorem.paragraph(sentence_count: [ *30..45 ].sample)
      content << Faker::Markdown.block_code
      content << Faker::Markdown.emphasis
    end
    content << "Hello **World**"
    content << "$$ F(x) = x^2 + 1 $$"
    content << "Text with $$E = mc^2$$ inside a sentence."
  end
end
