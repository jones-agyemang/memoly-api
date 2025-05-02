class CreateAuthenticationCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :authentication_codes do |t|
      t.string :code, null: false
      t.datetime :expires_at, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
