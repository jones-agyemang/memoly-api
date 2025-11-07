# frozen_string_literal: true

class AssignUncategorisedNotesToDefaultCollection < ActiveRecord::Migration[8.0]
  def up
    default_collection = Collection.find_by(label: Collection::DEFAULT_CATEGORY_LABEL)

    Note.for_each do |note|
      next if note.collection.present?

      note.collection = default_collection
      note.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
