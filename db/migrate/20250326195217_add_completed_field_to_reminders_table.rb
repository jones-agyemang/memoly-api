class AddCompletedFieldToRemindersTable < ActiveRecord::Migration[8.0]
  def change
    add_column :reminders, :completed, :boolean, default: false, null: false
  end
end
