json.data @records do |note|
  json.extract! note, :id, :raw_content, :source, :created_at, :updated_at, :public, :user_id

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

json.pagination do
  json.next @pagy.next
  json.limit @pagy.limit
  json.count @count
end
