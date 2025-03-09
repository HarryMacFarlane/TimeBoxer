class Workblock < ApplicationRecord
  belongs_to :user
  has_many :task_sessions, -> { order(:position) }, dependent: :destroy
  accepts_nested_attributes_for :task_sessions, allow_destroy: true
end
