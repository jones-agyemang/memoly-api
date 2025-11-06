class AddCollectionRefToNotes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_foreign_key :notes, :collections, validate: false
    validate_foreign_key :notes, :collections
  end

  def down
    remove_foreign_key :notes, :collections
  end
end
