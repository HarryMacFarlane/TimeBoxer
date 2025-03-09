FactoryBot.define do
  factory :workblock do
    duration { 60 } # example duration in minutes
    timestamp { Time.current }
    completed { false }
    association :user

    # You can also set up associations to task_sessions here if needed
    # trait :with_task_sessions do
    #   after(:create) do |workblock|
    #     create_list(:task_session, 3, workblock: workblock)
    #   end
    # end
  end
end
