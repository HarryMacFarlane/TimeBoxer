class RenameTypeColumnInSubtasks < ActiveRecord::Migration[8.0]
  def change
    rename_column :subtasks, :type, :subtask_type
  end
end
