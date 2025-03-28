class CreateReminders < ActiveRecord::Migration[8.0]
  def change
    create_table :reminders do |t|
      t.datetime :due_date
      t.references :note, null: false, foreign_key: true

      t.timestamps
    end
  end
end
