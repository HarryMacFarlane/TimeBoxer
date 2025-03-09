class CreateWorkblocks < ActiveRecord::Migration[8.0]
  def change
    create_table :workblocks do |t|
      t.integer :duration
      t.datetime :timestamp
      t.boolean :completed

      t.timestamps
    end
  end
end
