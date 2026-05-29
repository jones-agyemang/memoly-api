class ValidateCreateDoorkeeperTables < ActiveRecord::Migration[8.0]
  def change
    safety_assured {
      validate_foreign_key :oauth_access_tokens, :oauth_applications
    }
  end
end
