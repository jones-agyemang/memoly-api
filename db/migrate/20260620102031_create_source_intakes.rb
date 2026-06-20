class CreateSourceIntakes < ActiveRecord::Migration[8.0]
  def change
    create_enum :source_intake_type, %w[ url ]

    create_table :source_intakes do |t|
      t.enum :source_type, enum_type: :source_intake_type, null: false
      t.text :source

      t.timestamps
    end
  end
end
