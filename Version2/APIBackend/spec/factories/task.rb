FactoryBot.define do
  factory :task do
    association :user
    association :subject
    sequence(:name) { |n| "task#{n}" }
    description { Faker::Lorem.sentence }
    deadline { Faker::Time.forward(days: 10) }
    priority_level { rand(1..5) }
    expected_completion_time { rand(1..10) }
    time_spent { 0 }

    # Create task with subtasks
    trait :with_subtasks do
      after(:create) do |task|
        create_list(:subtask, 3, task: task)
      end
    end
  end
end
