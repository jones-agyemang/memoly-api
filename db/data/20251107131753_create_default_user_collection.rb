# frozen_string_literal: true

class CreateDefaultUserCollection < ActiveRecord::Migration[8.0]
  def up
    User.find_each { _1.collections.create label: Collection::DEFAULT_CATEGORY_LABEL }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
