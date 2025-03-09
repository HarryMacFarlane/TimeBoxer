class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :tag_name, null: false
      t.references :user, null: false, foreign_key: true
      t.string :description
      t.string :color

      t.timestamps
    end
    # Ensure each tag name is unique based on the user_id!
    add_index :tags, [ :tag_name, :user_id ], unique: true
  end
end
