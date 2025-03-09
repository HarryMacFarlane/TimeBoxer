class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.text :description
      t.datetime :deadline
      t.integer :priority_level, null: false
      t.integer :expected_completion_time
      t.integer :time_spent, null: false, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :tasks, [ :user_id, :name ], unique: true
  end
end
