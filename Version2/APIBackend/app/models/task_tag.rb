class TaskTag < ApplicationRecord
  belongs_to :task
  belongs_to :tag

  validates :task_id, uniqueness: { scope: :tag_id, message: "can't assign a tag twice to the same task!" }
end
