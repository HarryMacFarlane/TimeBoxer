class Subject < ApplicationRecord
  belongs_to :user
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, message: "This name has already been used for this user!" }
end
