require 'rails_helper'

RSpec.describe "Tasks API", type: :request do
  # Set up variables using factory bot to be used to verify correct functionality
  let!(:user) { FactoryBot.create(:user) }
  let!(:subject) { FactoryBot.create(:subject, user: user) }
  let!(:tag) { FactoryBot.create(:tag, tag_name: 'Test tag') }
  let!(:task) { FactoryBot.create(:task, :with_subtasks, user: user, subject: subject) }
  let!(:test_subtask) { FactoryBot.create(:subtask, task: task, name: 'Test subtask') }

  # Check that the user is properly associated with all the created objects
  before(:each) do
    # User checks
    user.reload
    expect(user.subjects.find_by(name: subject.name)).to eq(subject)
    expect(user.tasks.find_by(name: task.name)).to eq(task)
    # Task Check
    task.reload
    expect(task.subtasks.find_by(name: test_subtask.name)).to eq(test_subtask)
    expect(task.subtasks.find_by(name: test_subtask.name).position).to eq(4)
  end

  # Ensure the user is logged in and provide headers to be used to test requests
  let!(:headers) {
    post '/login', params: { user: { email: user.email, password: user.password } }, headers: { 'ACCEPT' => 'application/json' }
    token = response.headers['Authorization'].split(" ").last
    { 'Content-Type'=> 'application/json', 'Authorization' => "Bearer #{token}" }
  }

  let(:bad_headers) {
    { 'Content-Type'=> 'application/json', 'Authorization' => "Bearer deaniilfaefjiaedp120d13" }
  }
  describe "GET /tasks" do
    it "Returns the list of tasks upon valid request (single task)" do
      # Execute the request
      get '/tasks', headers: headers
      # Ensure correct response codes
      expect(response).to have_http_status(:ok)
      # Check returned data format for the task object
      response_data = JSON.parse(response.body)
      expect(response_data['data'][0]['id']).to eq(task.id.to_s)
      expect(response_data['data'][0]['attributes']['name']).to eq(task.name)
      expect(response_data['data'][0]['attributes']['subtasks_attributes'][3]['name']).to eq(test_subtask.name)
    end

    it "Returns the list of tasks upon valid request (multiple tasks)" do
      # Create a new task (at the second position)
      newTask = FactoryBot.create(:task, user: user, subject: subject)
      # Execute the request
      get '/tasks', headers: headers
      # Ensure correct response codes
      expect(response).to have_http_status(:ok)
      # Check returned data format for the task object
      response_data = JSON.parse(response.body)
      expect(response_data['data'][1]['id']).to eq(newTask.id.to_s)
    end

    it "Returns a 401 (unauthorized) error with invalid token" do
      # Execute the request
      get '/tasks', headers: bad_headers
      # Ensure correct response codes
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /tasks/:id" do
    let!(:showRoute) { "/tasks/#{task.id}" }
    it "Returns the requested task upon valid request" do
      # Execute the request
      get showRoute, headers: headers
      # Ensure correct response code
      expect(response).to have_http_status(:ok)
      # Check returned JSON
      response_data = JSON.parse(response.body)
      expect(response_data['data']['id']).to eq(task.id.to_s)
      task_attributes = response_data['data']['attributes']
      expect(task_attributes['name']).to eq(task.name)
      expect(task_attributes['description']).to eq(task.description)
      expect(task_attributes['tags']).to eq([])
      expect(task_attributes['subtasks_attributes'][3]['name']).to eq(test_subtask.name)
      expect(task_attributes['subtasks_attributes'][3]['description']).to eq(test_subtask.description)
    end

    it "Returns a 401 (unauthorized) error with invalid token" do
      # Execute the request
      get showRoute, headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "Returns a 404 (not found) error for task that does not exist" do
      get '/tasks/9999999', headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /tasks" do
    let!(:deadline) { DateTime.now.utc }
    let!(:createParams) { { task: { name: 'New task', subject_id: subject.id, tag_ids: [ tag.id ], priority_level: 5, deadline: deadline } } }

    it "Creates a new task, assigns subject and tags upon valid request (no subtasks)" do
      post '/tasks', params: createParams.to_json, headers: headers
      expect(response).to have_http_status(:created)
      # Check that the body was correctly created
      response_data = JSON.parse(response.body)
      task_attributes = response_data['data']['attributes']
      # Correctly sets the subject
      expect(task_attributes['subject']['id']).to eq(subject.id)
      expect(task_attributes['subject']['name']).to eq(subject.name)
      # Correctly sets the tag
      expect(task_attributes['tags'][0]['id']).to eq(tag.id)
      expect(task_attributes['tags'][0]['tag_name']).to eq(tag.tag_name)
      # Ensure consistency with datetime creation
      expect(task_attributes['deadline']).to eq(deadline.iso8601)
    end

    it "Creates a new task, with subtasks upon valid request" do
      # Add some subtasks to the params
      createParams[:task][:subtasks_attributes] = []
      createParams[:task][:subtasks_attributes][0] = { name: 'Subtask1', description: 'Example', completed: false, subtask_type: "Organize" }
      # Execute the request
      post '/tasks', params: createParams.to_json, headers: headers
      expect(response).to have_http_status(:created)
      # Check that the body was correctly created
      response_data = JSON.parse(response.body)
      subtask_attributes = response_data['data']['attributes']['subtasks_attributes'][0]
      expect(subtask_attributes['name']).to eq('Subtask1')
      expect(subtask_attributes['description']).to eq('Example')
      expect(subtask_attributes['completed']).to eq(false)
      expect(subtask_attributes['subtask_type']).to eq('Organize')
    end

    it "Returns a 401 (unauthorized) error with invalid token" do
      post '/tasks', params: createParams.to_json, headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "Returns a 422 (unprocessable_entity) error if the task has the same name" do
      # Assign same name for new task params
      createParams[:task][:name] = task.name
      # Execute the request
      post '/tasks', params: createParams.to_json, headers: headers
      # Ensure correct response code
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "Returns a 400 (bad request) error with invalid parameters" do
      # Give the correct nested params, but a bad outer param
      badCreateParams = { nottask: createParams[:task] }
      # Execute the request
      post '/tasks', params: badCreateParams.to_json, headers: headers
      # Ensure correct response code
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "PATCH /tasks" do
    # Create update params to modify the created task
    let!(:updateParams) { { task: { id: task.id, subtasks_attributes: [] } } }
    it "Returns an updated object upon valid request (new_name)" do
      # Change the update params to include a new name and execute the request
      updateParams[:task][:name] = "New Task Name"
      patch '/tasks', params: updateParams.to_json, headers: headers
      # Ensure correct response status code
      expect(response).to have_http_status(:ok)
      # Verify name has been successfully changed
      response_data = JSON.parse(response.body)
      expect(response_data['data']['id']).to eq(task.id.to_s)
      expect(response_data['data']['attributes']['name']).to eq("New Task Name")
    end

    it "Returns an updated object upon valid request (new tags and subject)" do
      # Check that the current task is assigned to the original subject
      expect(task.subject.id).to eq(subject.id)
      # Make a new subject, and assign it to the user
      new_subject = FactoryBot.create(:subject, user: user, name: 'PATCH task test subject')
      # Add both of their ids to the update parameters
      updateParams[:task][:subject_id] = new_subject.id
      updateParams[:task][:tag_ids] = []
      updateParams[:task][:tag_ids][0] = tag.id
      # Execute the request
      patch "/tasks", params: updateParams.to_json, headers: headers
      # Ensure correct response status code
      expect(response).to have_http_status(:ok)

      # Check that the tags where correctly assigned
      response_data = JSON.parse(response.body)
      expect(response_data['data']['id']).to eq(task.id.to_s)
      expect(response_data['data']['attributes']['subject']['id']).to eq(new_subject.id)
      expect(response_data['data']['attributes']['tags'][0]['id']).to eq(tag.id)
    end

    it "Returns an updated object upon valid request (new subtasks)" do
      # Create the params for a new subtask, and add them to the updateParams
      new_subtask_params = { name: 'PATCH test subtask', description: "Example", completed: false, subtask_type: "Execute" }
      updateParams[:task][:subtasks_attributes][0] = new_subtask_params
      # Execute the request
      patch "/tasks", params: updateParams.to_json, headers: headers
      # Ensure correct response status code
      expect(response).to have_http_status(:ok)
      # Check that returned object is correct
      response_data = JSON.parse(response.body)
      new_subtask_data = response_data['data']['attributes']['subtasks_attributes'][4]
      # Check fields for the new subtask
      expect(new_subtask_data['name']).to eq("PATCH test subtask")
      expect(new_subtask_data['description']).to eq("Example")
      expect(new_subtask_data['completed']).to be false
      expect(new_subtask_data['subtask_type']).to eq("Execute")
      # Check the subtask was created in the db
      expect(Subtask.find(new_subtask_data['id'])).to be_valid
    end

    it "Returns an updated object upon valid request (deleting subtask)" do
      updateParams[:task][:subtasks_attributes] = [ { id: test_subtask.id, _destroy: true } ]
      # Execute the request
      patch "/tasks", params: updateParams.to_json, headers: headers
      expect(response).to have_http_status(:ok)
      # Check database has deleted the subtask
      expect(Subtask.find_by(id: test_subtask.id)).to be_nil
      # Check that the returned object no longer has 4 subtasks (now 3)
      response_data = JSON.parse(response.body)
      subtask_list = response_data['data']['attributes']['subtasks_attributes']
      expect(subtask_list.count).to eq(3)
    end

    it "Returns a 400 (bad request) error with absence of task key in params" do
      updateParams.delete(:task)
      patch "/tasks", params: updateParams.to_json, headers: headers
      expect(response).to have_http_status(:bad_request)
    end

    it "Returns a 400 (bad request) error with absence of nested name key" do
      updateParams[:task].delete(:id)
      patch "/tasks", params: updateParams.to_json, headers: headers
      expect(response).to have_http_status(:bad_request)
    end

    it "Returns a 401 (unauthorized) error with invalid token" do
      patch "/tasks", params: updateParams.to_json, headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "Returns a 404 (not found) error with non-existing name (for user)" do
      updateParams[:task][:id] = 9999999
      patch "/tasks", params: updateParams.to_json, headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it "Returns a 422 (unprocessible entity) when trying to update name to already existing name (for user)" do
      # Create new task with name
      FactoryBot.create(:task, user: user, subject: subject, name: "422 update check")
      # Assign new name to updateParams
      updateParams[:task][:name] = "422 update check"
      # Execute the request
      patch "/tasks", params: updateParams.to_json, headers: headers
      # Ensure correct response status code
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /tasks" do
    let!(:destroyParams) { { task: { id: task.id } } }

    it "Destroys object in database upon valid request" do
      # Execute the request
      delete "/tasks", params: destroyParams.to_json, headers: headers
      expect(response).to have_http_status(:ok)
      # Check the task and its associated subtasks (only going to check the one we are currently tracking) have been destroyed
      expect(Task.exists?(task.id)).to be false
      expect(Subtask.exists?(test_subtask.id)).to be false
    end

    it "Returns a 400 (bad request) error with absence of task key in params" do
      destroyParams.delete(:task)
      delete "/tasks", params: destroyParams.to_json, headers: headers
      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 401 (unauthorized) error with invalid token" do
      delete "/tasks", params: destroyParams.to_json, headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "Returns a 404 (not found) error for non-existing task name" do
      destroyParams[:task][:id] = 99999
      delete "/tasks", params: destroyParams.to_json, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
