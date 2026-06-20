class ValidateUserFkOnSourceIntake < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :source_intakes, :users
  end
end
