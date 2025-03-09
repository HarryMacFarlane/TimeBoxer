FactoryBot.define do
  factory :subject do
    name { "Test Subject" }
    description { "Test description" }
    association :user  # Associates the subject with a user
  end
end
