class AddSubjectToTasks < ActiveRecord::Migration[8.0]
  def change
    add_reference :tasks, :subject, null: false, foreign_key: true
  end
end
