class AddUserReferenceToSourceIntake < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :source_intakes, :user, null: false, index: { algorithm: :concurrently }
  end
end
