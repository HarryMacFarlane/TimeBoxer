FactoryBot.define do
  factory :task_session do
    start_time { Time.current }
    end_time { Time.current + 60.minutes } # Default to 1-hour duration
    duration { 60 }
    position { 1 }
    association :subtask
    association :workblock

    # You can add traits or additional logic as needed
  end
end
