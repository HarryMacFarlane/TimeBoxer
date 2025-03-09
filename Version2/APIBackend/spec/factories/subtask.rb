FactoryBot.define do
  factory :subtask do
    association :task
    sequence(:name) { |n| "subtask number #{n}" }
    subtask_type { Subtask.subtask_types.keys.sample }
    description { Faker::Lorem.sentence }
    completed { false }
  end
end
