class AddUserFkToSourceIntake < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :source_intakes, :users, validates: false, validate: false
  end
end
