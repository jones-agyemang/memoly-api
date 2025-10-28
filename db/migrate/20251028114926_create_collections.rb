class CreateCollections < ActiveRecord::Migration[8.0]
  def change
    enable_extension "ltree" unless extension_enabled?("ltree")

    create_table :collections do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }

      t.string :label, null: false
      t.string :slug, null: false

      t.references :parent, foreign_key: { to_table: :collections, on_delete: :cascade }
      t.ltree :path, null: false

      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :collections, [ :user_id, :parent_id, :slug ], unique: true
    add_index :collections, :path, using: :gist
    add_index :collections, [ :user_id, :parent_id, :position ]
  end
end
