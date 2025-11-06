class AddCollectionNoteReference < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
   add_reference :notes, :collection, null: true, index: { algorithm: :concurrently }
  end
end
