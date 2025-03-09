class TaskSession < ApplicationRecord
  belongs_to :subtask
  belongs_to :workblock


  before_create :set_position, :reorder_positions
  before_update :reorder_positions_on_update
  before_destroy :reorder_positions_after_deletion

  private
  # Set position to the last if not provided
  def set_position
    self.position ||= workblock.task_sessions.maximum(:position).to_i + 1
  end

  # Reorder task_sessions before creation
  def reorder_positions
    workblock.task_sessions.where("position >= ?", self.position).find_each do |task_session|
      task_session.update(position: task_session.position + 1)
    end
  end

  # Reorder task_sessions before updating a task_session's position
  def reorder_positions_on_update
    # Only reorder if the position has changed
    return if self.position == self.position_was

    # If position is updated, we need to adjust the other task sessions
    if self.position < self.position_was
      # Move all task_sessions between the old and new position up by 1
      workblock.task_sessions.where("position >= ? AND position < ?", self.position, self.position_was).find_each do |task_session|
        task_session.update_columns(position: task_session.position + 1)
      end
    else
      # Move all task_sessions between the old and new position down by 1
      workblock.task_sessions.where("position <= ? AND position > ?", self.position, self.position_was).find_each do |task_session|
        task_session.update_columns(position: task_session.position - 1)
      end
    end
  end

  # Reorder task_sessions after a task_session is destroyed
  def reorder_positions_after_deletion
    workblock.task_sessions.where("position > ?", self.position).find_each do |task_session|
      task_session.update(position: task_session.position - 1)
    end
  end
end
