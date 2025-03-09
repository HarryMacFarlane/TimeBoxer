class AddUserToWorkblocks < ActiveRecord::Migration[8.0]
  def change
    add_reference :workblocks, :user, null: false, foreign_key: true
  end
end
