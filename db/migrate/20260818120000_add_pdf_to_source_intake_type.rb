class AddPdfToSourceIntakeType < ActiveRecord::Migration[8.0]
  def up
    add_enum_value :source_intake_type, "pdf"
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      "PostgreSQL enum values cannot be removed directly"
  end
end
