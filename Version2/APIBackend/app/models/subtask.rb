class Subtask < ApplicationRecord
  belongs_to :task
  before_create :set_position # So can automatically set the position if it is not explicitly provided
  before_update :reorder_positions_on_update
  before_destroy :reorder_positions # Automatically correct positions of subtasks based o =n the one that is deleted
  enum :subtask_type, { Organize: 0, Execute: 1, Verify: 2, Submit: 3, General: 4 }

  validates :name, presence: true, uniqueness: { scope: :task_id }
  validates :description, presence: true
  validates :completed, inclusion: { in: [ true, false ] }

  private

  def set_position
    self.position ||= task.subtasks.maximum(:position).to_i + 1
  end

  def reorder_positions
    Subtask.where(task_id: task_id)
           .where("position >= ?", position)
           .update_all("position = position - 1")
  end

  def reorder_positions_on_update
    # Only reorder if the position has changed
    return if self.position == self.position_was

    if self.position < self.position_was
      # Move all subtasks between the old and new position up by 1 without triggering callbacks
      task.subtasks.where("position >= ? AND position < ?", self.position, self.position_was).find_each do |subtask|
        subtask.update_columns(position: subtask.position + 1)
      end
    else
      # Move all subtasks between the old and new position down by 1 without triggering callbacks
      task.subtasks.where("position <= ? AND position > ?", self.position, self.position_was).find_each do |subtask|
        subtask.update_columns(position: subtask.position - 1)
      end
    end
  end
end
