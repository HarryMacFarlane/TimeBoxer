class MakeSubjectIdNullableInTasks < ActiveRecord::Migration[8.0]
  def change
    change_column_null :tasks, :subject_id, true  # Allow NULL values
  end
end
