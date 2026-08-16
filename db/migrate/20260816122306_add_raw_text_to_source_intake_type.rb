class AddRawTextToSourceIntakeType < ActiveRecord::Migration[8.0]
  def up
    add_enum_value :source_intake_type, "raw_text"
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      "PostgreSQL enum values cannot be removed directly"
  end
end
