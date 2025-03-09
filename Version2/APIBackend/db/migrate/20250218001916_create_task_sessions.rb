class CreateTaskSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :task_sessions do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.references :subtask, null: false, foreign_key: true
      t.references :workblock, null: false, foreign_key: true
      t.time :duration
      t.integer :position

      t.timestamps
    end
  end
end
