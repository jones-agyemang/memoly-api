class AddProcessingStateToSourceIntakes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :source_intakes, :status, :string, default: "pending", null: false
    add_column :source_intakes, :validation_result, :jsonb, default: {}, null: false
    add_column :source_intakes, :error_reason, :text

    add_index :source_intakes, :status, algorithm: :concurrently
  end
end
