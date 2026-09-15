json.extract! collection, :id, :label, :slug, :path, :parent_id, :position, :public

if collection.children.any?
  json.children Collection.ordered_siblings(collection.children) do |child|
    json.partial! "collections/collection", locals: { collection: child }
  end
else
  json.children []
end
