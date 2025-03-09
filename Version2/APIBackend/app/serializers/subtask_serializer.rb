class SubtaskSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :completed, :position

  attribute :subtask_type do |subtask|
    subtask.subtask_type # This returns the enum as a string
  end
end
