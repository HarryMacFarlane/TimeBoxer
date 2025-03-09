class ChangeDurationToIntegerInTaskSessions < ActiveRecord::Migration[8.0]
  def change
    change_column :task_sessions, :duration, :integer
  end
end
