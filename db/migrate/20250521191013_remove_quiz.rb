class RemoveQuiz < ActiveRecord::Migration[8.0]
  def change
    safety_assured { drop_table :quizzes }
  end
end
