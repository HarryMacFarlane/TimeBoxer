class TaskSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :deadline, :priority_level, :expected_completion_time, :time_spent
  attribute :deadline do |task|
    task.deadline.iso8601 # Ensures consistent format
  end
  attribute :subject do |task|
    if task.subject.present? # Check if subject is not nil
      {
        id: task.subject.id,
        name: task.subject.name
      }
    end
  end

  attribute :tags do |task|
    task.tags.map do |tag|
      {
        id: tag.id,
        tag_name: tag.tag_name
      }
    end
  end
  # No need to create a unique serializer as they will only ever be accessed through /tasks
  attribute :subtasks_attributes do |task|
    task.subtasks.map do |subtask|
      {
        id: subtask.id,
        name: subtask.name,
        description: subtask.description,
        completed: subtask.completed,
        position: subtask.position,
        subtask_type: subtask.subtask_type
      }
    end
  end
end
