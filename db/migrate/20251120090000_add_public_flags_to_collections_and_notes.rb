class AddPublicFlagsToCollectionsAndNotes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :collections, :public, :boolean, default: false, null: false
    add_index :collections, :public, algorithm: :concurrently

    add_column :notes, :public, :boolean, default: false, null: false
    add_index :notes, :public, algorithm: :concurrently
  end
end
