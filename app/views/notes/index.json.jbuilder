json.array!(@notes) do |note|
  json.id note.id
  json.raw_content note.raw_content
  json.source note.source
  json.created_at note.created_at
  json.updated_at note.updated_at

  json.collection do
    json.id note.collection&.id
    json.label note.collection&.label
  end

  json.user do
    json.email note.user&.email
  end

  json.reminders note.reminders do |reminder|
    json.due_date reminder.due_date&.to_date&.iso8601
    json.completed reminder.completed
  end
end
