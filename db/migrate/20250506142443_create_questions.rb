class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.string :raw_content
      t.string :explanation

      t.timestamps
    end
  end
end
