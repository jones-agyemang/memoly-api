# frozen_string_literal: true

class SetPositionForDefaultCollection < ActiveRecord::Migration[8.0]
  ALWAYS_ON_TOP = -1

  def up
    Collection
      .where(label: Collection::DEFAULT_CATEGORY_LABEL)
      .find_each { _1.update_attribute(:position, ALWAYS_ON_TOP) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
