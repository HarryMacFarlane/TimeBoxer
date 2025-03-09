class CreateTaskTags < ActiveRecord::Migration[8.0]
  def change
    create_table :task_tags do |t|
      t.references :task, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    # Ensure a tag is not added twice to the same task
    add_index :task_tags, [ :task_id, :tag_id ], unique: true
  end
end
