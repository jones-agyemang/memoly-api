def seed_collection
  puts "Seeding Collection Data..."
  delete_existing_collections
  puts "Successfully seeded Collection Data!"

  user = User.find_or_create_by(email: "mightyj@hotmail.co.uk")
  user.collections.create(label: Collection::DEFAULT_CATEGORY_LABEL, public: true)

  parent = Collection.create(user:, label: "Mathematics", parent_id: nil, position: 0, public: true)
  Note.create(user:, collection_id: parent.id, raw_content: "Gaussian Theorem is fun", public: true)
  Collection.create(user:, label: "Linear Algebra", parent:, position: 0, public: true)

  parent = Collection.create(user:, label: "Computer Science", parent_id: nil, position: 0, public: true)
  Collection.create(user:, label: "Quantum Computing", parent:, position: 0, public: true)
  Collection.create(user:, label: "Advanced Programming", parent:, position: 1, public: true)

  parent = Collection.create(user:, label: "History", parent_id: nil, position: 0, public: true)
    Collection.create(user:, label: "Modern Warfare", parent:, position: 1, public: true)
    Collection.create(user:, label: "Ancient Battles", parent:, position: 2, public: true)
    parent = Collection.create(user:, label: "Historical Figures", parent:, position: 3, public: true)
      parent = Collection.create(user:, label: "Jesus Christ", parent:, position: 4, public: true)
        parent = Collection.create(user:, label: "Gospel", parent:, position: 0, public: true)
        parent = Collection.create(user:, label: "Post-Apocalyptic", parent:, position: 0, public: true)
end

def delete_existing_collections
  Reminder.delete_all
  Note.delete_all
  Collection.delete_all
end
