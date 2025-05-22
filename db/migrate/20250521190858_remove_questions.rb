class RemoveQuestions < ActiveRecord::Migration[8.0]
  def change
    safety_assured { drop_table :questions }
  end

  # def down
  #   create_table :questions do |t|
  #     t.string :raw_content
  #     t.string :explanation

  #     t.timestamps
  #   end
  # end
end
