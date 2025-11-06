json.(@note, :id, :raw_content, :source, :created_at, :updated_at)
json.user { json.email @note.user&.email }
json.collection { json.label @note.collection&.label }
json.reminders @note.reminders do |reminder|
  json.due_date reminder.due_date&.to_date&.iso8601
  json.completed reminder.completed
end
