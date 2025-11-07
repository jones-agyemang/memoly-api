json.(@note, :id, :raw_content, :source, :created_at, :updated_at)
json.user { json.email @note.user&.email }
json.collection do
  json.id @note.collection&.id
  json.label @note.collection&.label
end
json.reminders @note.reminders do |reminder|
  json.due_date reminder.due_date&.to_date&.iso8601
  json.completed reminder.completed
end
