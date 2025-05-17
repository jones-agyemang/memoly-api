class AddUserReferenceToNotes < ActiveRecord::Migration[8.0]
  def change
    add_reference :notes, :user, null: true, foreign_key: true
  end
end
