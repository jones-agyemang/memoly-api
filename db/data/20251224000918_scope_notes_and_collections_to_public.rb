# frozen_string_literal: true

class ScopeNotesAndCollectionsToPublic < ActiveRecord::Migration[8.0]
  def up
    email = 'mightyj@hotmail.co.uk'
    user = User.find_by!(email:)

    ActiveRecord::Base.transaction do
      collections = user.collections
      collection_ids = collections.select(:id)

      say_with_time("Marking collections for #{email} as public") do
        collections.update_all(public: true)
      end

      say_with_time("Marking notes for #{email} as public") do
        Note.where(collection_id: collection_ids).update_all(public: true)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
