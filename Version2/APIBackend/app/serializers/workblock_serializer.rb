class WorkblockSerializer
  include JSONAPI::Serializer

  attributes :duration, :timestamp, :completed

  attribute :task_sessions_attributes do |workblock|
    workblock.task_sessions.map do |task_session|
      {
        id: task_session.id,
        start_time: task_session.start_time,
        end_time: task_session.end_time,
        duration: task_session.duration,
        subtask_id: task_session.subtask.id,
        task_id: task_session.subtask.task.id
      }
    end
  end
end
