json.extract! collection, :id, :label, :slug, :path, :parent_id, :position, :public

json.user do
  json.email collection.user&.email
end

visible_notes = filtered_notes_for(collection)

json.notes visible_notes do |note|
  json.extract! note, :id, :raw_content, :source, :public, :collection_id

  json.user do
    json.email note.user&.email
  end
end

json.children children_for(collection) do |child|
  json.partial! "discovery/collection", locals: { collection: child }
end
