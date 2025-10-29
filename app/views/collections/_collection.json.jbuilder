json.extract! collection, :id, :label, :slug, :path, :parent_id, :position

if collection.children.any?
  json.children collection.children do |child|
    json.partial! "collections/collection", collection: [ child ]
  end
else
  json.children []
end
