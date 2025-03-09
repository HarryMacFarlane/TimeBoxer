class AddUniqueIndexToSubjectName < ActiveRecord::Migration[8.0]
  def change
    add_index :subjects, [:name, :user_id], unique: true
  end
end
