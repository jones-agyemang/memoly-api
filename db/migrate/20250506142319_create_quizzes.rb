class CreateQuizzes < ActiveRecord::Migration[8.0]
  def change
    create_table :quizzes do |t|
      t.string :topic

      t.timestamps
    end
  end
end
