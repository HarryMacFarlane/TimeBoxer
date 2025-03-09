RSpec.describe Task, type: :model do
  let!(:user) { FactoryBot.create(:user) }
  let!(:subject) { FactoryBot.create(:subject, user: user) }
  let!(:task) { FactoryBot.create(:task, user: user, subject: subject) }

  before(:each) do
    expect(user).to be_valid
    expect(subject).to be_valid
    expect(task).to be_valid
    user.reload
    subject.reload
    task.reload
  end
  context "Creation through application records"
    it "Creates a subtask using a direct call" do
      Subtask.new(name: '')
    end
    it "Checks that it is possibele to create subtasks through tasks" do
      subtask = task.subtasks.new(name: 'Subtask1', subtask_type: :Organize, description: 'Test Description', completed: false)
      expect(subtask).to be_valid
      expect(subtask.task_id).to eq(task.id)
    end

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(task).to be_valid
    end

    it 'is not valid without a name' do
      task.name = nil
      expect(task).not_to be_valid
    end

    it 'is not valid without a priority_level' do
      task.priority_level = nil
      expect(task).not_to be_valid
    end

    it 'is not valid with duplicate name (for the same user)' do
      newTask = FactoryBot.build(:task, user: user, name: task.name)
      expect(newTask).not_to be_valid
    end
  end

  context 'associations' do
    it 'belongs to a user' do
      expect(task.user).to eq(user)
    end

    it 'has many subtasks' do
      task_with_subtasks = FactoryBot.create(:task, :with_subtasks, user: user, subject: subject)
      expect(task_with_subtasks.subtasks.count).to eq(3)
    end
  end

  context 'nested attributes' do
    it 'allows creation of subtasks through task' do
      task_with_subtasks = FactoryBot.create(:task, :with_subtasks, user: user, subject: subject)
      expect(task_with_subtasks.subtasks.count).to eq(3)
    end

    it 'Re-assigns subtask positions in certain update context' do
      new_task = FactoryBot.create(:task, :with_subtasks, user: user, subject: subject)
      new_subtask = FactoryBot.create(:subtask, name: 'New Subtask', task: new_task)
      expect(new_subtask.position).to eq(4)
      updateParams = { subtasks_attributes: [ { id: new_subtask.id, position: 1 } ] }
      new_task.update(updateParams)
      new_task.reload
      expect(new_task.subtasks.find_by(name: "New Subtask").position).to eq(1) # Check the order is correct
    end

    it 'deletes single subtasks using nested update params' do
      task_with_subtasks = FactoryBot.create(:task, :with_subtasks, user: user, subject: subject)
      new_subtask = FactoryBot.create(:subtask, task: task_with_subtasks, name: 'Test subtask')
      task_with_subtasks.reload
      expect(task_with_subtasks.subtasks.count).to eq(4)
      task_with_subtasks.update({ subtasks_attributes: [ { id: new_subtask.id, _destroy: true } ] })
      task_with_subtasks.reload
      expect(task_with_subtasks.subtasks.count).to eq(3)
      expect(Subtask.exists?(new_subtask.id)).to be_falsey
    end

    it 'deletes subtasks when task is deleted' do
      task_with_subtasks = FactoryBot.create(:task, :with_subtasks, user: user, subject: subject)
      subtask_ids = task_with_subtasks.subtasks.pluck(:id)

      task_with_subtasks.destroy

      subtask_ids.each do |id|
        expect(Subtask.exists?(id)).to be_falsey
      end
    end
  end
end
