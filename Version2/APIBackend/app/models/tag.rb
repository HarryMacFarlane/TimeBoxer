class Tag < ApplicationRecord
  belongs_to :user

  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags

  validates :tag_name, presence: true, uniqueness: { scope: :user_id, message: "should be unique within the scope of the user" }
end
