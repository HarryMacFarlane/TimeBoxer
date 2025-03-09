class Task < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  has_many :subtasks, -> { order(:position) }, dependent: :destroy
  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :priority_level, presence: true
  validates :time_spent, presence: true, numericality: { greater_than_or_equal_to: 0 }

  accepts_nested_attributes_for :subtasks, allow_destroy: true
end
