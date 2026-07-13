class AddPublicFieldToSourceIntake < ActiveRecord::Migration[8.0]
  def change
    add_column :source_intakes, :public, :boolean, default: false
  end
end
