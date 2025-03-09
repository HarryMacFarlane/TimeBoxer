FactoryBot.define do
  factory :tag do
    tag_name { 'Test Tag Name' }
    description { 'Test Tag Description' }
    association :user
  end
end
