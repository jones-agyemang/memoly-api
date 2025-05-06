class AddChoicesAndAnswerFieldToQuestions < ActiveRecord::Migration[8.0]
  def change
    add_column :questions, :answer, :string
    add_column :questions, :choices, :string, array: true, default: []
  end
end
