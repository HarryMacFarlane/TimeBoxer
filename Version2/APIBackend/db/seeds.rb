# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.create!(
  email: 'test@example.com',
  password: 'password123',  # Change this to a secure default password
  password_confirmation: 'password123'
) unless User.exists?(email: 'test@example.com')

puts "Seeded default user: test@example.com"

user = User.find_by(email: 'test@example.com')

subject1 = user.subjects.create!(
  { name: "Subject1", description: "Subject1 test description" }
)
subject2 = user.subjects.create!(
  { name: "Subject2", description: "Subject2 test description" }
)
puts "Seeded default user with 2 test subjects"

tag1 = user.tags.create!(
  { tag_name: "Tag1", description: "Tag1 test description" }
)
tag2 = user.tags.create!(
  { tag_name: "Tag2", description: "Tag2 test description" }
)
puts "Seeded default user with 2 test tags"

task1 = user.tasks.create!(
  { name: "Task1", description: "Task1 test description", deadline: Time.now, priority_level: 1, subject_id: subject1.id, tag_ids: [ tag1.id ] }
)
task2 = user.tasks.create!(
  { name: "Task2", description: "Task2 test description", deadline: Time.now, priority_level: 5, subject_id: subject2.id, tag_ids: [ tag2.id ] }
)
puts "Seeded default user with 2 test tasks"

subtask1 = task1.subtasks.create!(
  { name: "Subtask1", description: "Subtask1 test description", completed: false, subtask_type: "Organize" }
)
subtask2 = task2.subtasks.create!(
  { name: "Subtask2", description: "Subtask2 test description", completed: false, subtask_type: "Organize" }
)
puts "Seeded default user with 2 test subtasks"

workblock1 = user.workblocks.create!(
  { duration: 10, timestamp: Time.now, completed: false }
)
workblock2 = user.workblocks.create!(
  { duration: 5, timestamp: Time.now, completed: true }
)
puts "Seeded default user with 2 test workblocks"

workblock1.task_sessions.create!(
  { start_time: Time.now, subtask_id: subtask1.id, duration: 4 }
)
workblock2.task_sessions.create!(
  { start_time: Time.now, end_time: Time.now, subtask_id: subtask2.id, duration: 5 }
)
puts "Seeded default user with 2 test task sessions"
