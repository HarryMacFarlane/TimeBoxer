require 'rails_helper'

RSpec.describe Workblock, type: :model do
  let!(:user) { FactoryBot.create(:user) }
  let!(:subject) { FactoryBot.create(:subject, user: user) }
  let!(:task) { FactoryBot.create(:task, :with_subtasks, user: user, subject: subject) }
  let!(:subtask) { FactoryBot.create(:subtask, task: task) }
  let!(:workblock) { FactoryBot.create(:workblock, user: user) }

  describe "creates new workblocks with valid inputs" do
    let!(:workblock_params) { { completed: false, duration: 100, timestamp: Time.current } }

    it "Basic Workblock" do
      user.workblocks.new(workblock_params)
      expect(user.workblocks.count).to eq(1)
    end
  end

  describe "nested attributes for task sessions" do
    it 'Creates task sessions (update)' do
      expect(workblock).to be_valid
      updateParams = { task_sessions_attributes: [ { start_time: Time.current, end_time: Time.current + 60.minutes, duration: 100, subtask_id: subtask.id } ] }
      workblock.update(updateParams)
      unless workblock.save
        puts workblock.errors.full_messages
      end
      expect(workblock.task_sessions.count).to eq(1) # Since no task sessions should be in the db, it should have 1
    end

    it "Deletes a nested task sessions (update)" do
      new_task_session = FactoryBot.create(:task_session, workblock: workblock, subtask: subtask)
      workblock.reload
      updateParams = { task_sessions_attributes: [ { id: new_task_session.id, _destroy: true } ] }
      workblock.update(updateParams)
      expect(TaskSession.exists?(new_task_session.id)).to be_falsey
    end

    it "Deletes all nested task sessions (destroy)" do
      new_task_session = FactoryBot.create(:task_session, workblock: workblock, subtask: subtask)
      workblock.destroy
      expect(TaskSession.exists?(new_task_session.id)).to be_falsey
    end
  end
end
