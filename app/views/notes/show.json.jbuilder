json.(@note, :id, :raw_content, :source, :created_at, :updated_at)
json.reminders @note.reminders do |reminder|
  json.due_date reminder.due_date&.to_date&.iso8601
  json.completed reminder.completed
end
