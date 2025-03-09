FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }  # Ensures unique email for each user
    password { 'password123' }                         # Set a default password
    password_confirmation { password }                  # Ensure password confirmation matches
  end
end
