def seed_collection
  puts "Seeding Collection Data..."
  delete_existing_collections
  puts "Successfully seeded Collection Data!"

  user = User.find_or_create_by(email: "mightyj@hotmail.co.uk")

  parent = Collection.create(user:, label: "Mathematics", parent_id: nil, position: 0)
  Collection.create(user:, label: "Linear Algebra", parent:, position: 0)

  parent = Collection.create(user:, label: "Computer Science", parent_id: nil, position: 0)
  Collection.create(user:, label: "Quantum Computing", parent:, position: 0)
  Collection.create(user:, label: "Advanced Programming", parent:, position: 1)

  parent = Collection.create(user:, label: "History", parent_id: nil, position: 0)
    Collection.create(user:, label: "Modern Warfare", parent:, position: 1)
    Collection.create(user:, label: "Ancient Battles", parent:, position: 2)
    parent = Collection.create(user:, label: "Historical Figures", parent:, position: 3)
      parent = Collection.create(user:, label: "Jesus Christ", parent:, position: 4)
        parent = Collection.create(user:, label: "Gospel", parent:, position: 0)
        parent = Collection.create(user:, label: "Post-Apocalyptic", parent:, position: 0)
end

def delete_existing_collections
  Collection.delete_all
end
