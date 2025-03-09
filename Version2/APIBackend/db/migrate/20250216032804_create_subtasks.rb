class CreateSubtasks < ActiveRecord::Migration[8.0]
  def change
    create_table :subtasks do |t|
      t.string :name, null: false
      t.integer :type, null: false
      t.text :description
      t.boolean :completed, null: false, default: false
      t.references :task, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end
    add_index :subtasks, [ :task_id, :name ], unique: true
  end
end
