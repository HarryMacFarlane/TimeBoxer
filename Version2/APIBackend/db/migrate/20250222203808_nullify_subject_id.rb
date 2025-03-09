class NullifySubjectId < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :tasks, :subjects
    add_foreign_key :tasks, :subjects, on_delete: :nullify
  end
end
