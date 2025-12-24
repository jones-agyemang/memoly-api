json.array! @top_level_collections do |collection|
  json.partial! "discovery/collection", locals: { collection: collection }
end
