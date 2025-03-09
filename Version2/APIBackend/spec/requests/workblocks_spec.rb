require 'rails_helper'

RSpec.describe "Workblocks API", type: :request do
  # Set up variables using FactoryBot to be used to verify correct functionality
  let!(:user) { FactoryBot.create(:user) }
  let!(:workblock) { FactoryBot.create(:workblock, user: user) }
  let!(:task) { FactoryBot.create(:task, user: user) }
  let!(:subtask) { FactoryBot.create(:subtask, task: task) }

  # Ensure the user is logged in and provide headers to be used to test requests
  let!(:headers) {
    post '/login', params: { user: { email: user.email, password: user.password } }, headers: { 'ACCEPT' => 'application/json' }
    token = response.headers['Authorization'].split(" ").last
    { 'Content-Type'=> 'application/json', 'Authorization' => "Bearer #{token}" }
  }

  let(:bad_headers) {
    { 'Content-Type'=> 'application/json', 'Authorization' => "Bearer invalidtoken" }
  }

  describe "GET /workblocks" do
    it "Returns the list of workblocks upon valid request" do
      get '/workblocks', headers: headers
      expect(response).to have_http_status(:ok)
      response_data = JSON.parse(response.body)
      expect(response_data['data'][0]['id']).to eq(workblock.id.to_s)
    end

    it "Returns a 401 (unauthorized) error with invalid token" do
      get '/workblocks', headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /workblocks/#id" do
    it "Returns the requested workblock upon valid request" do
      get "/workblocks/#{workblock.id}", headers: headers
      expect(response).to have_http_status(:ok)
      response_data = JSON.parse(response.body)
      expect(response_data['data']['id']).to eq(workblock.id.to_s)
    end

    it "Returns a 401 (unauthorized) error with invalid token" do
      get "/workblocks/#{workblock.id}", headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "Returns a 404 (not found) error for non-existing workblock" do
      get "/workblocks/999999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /workblocks" do
    let(:createParams) { { workblock: { timestamp: Time.current, duration: 10, completed: true, task_sessions_attributes: [ { start_time: Time.current, end_time: Time.current + 60.minutes, duration: 100, subtask_id: subtask.id } ] } } }

    it "Creates a new workblock upon valid request" do
      post '/workblocks', params: createParams.to_json, headers: headers

      # Ensure correct response status code, and parse the response
      expect(response).to have_http_status(:created)
      response_data = JSON.parse(response.body)

      # Ensure the serializer is returning data correctly
      expect(response_data['data']['attributes']['duration']).to eq(10)
      expect(response_data['data']['attributes']['completed']).to be_truthy
      expect(response_data['data']['attributes']['task_sessions_attributes'][0]['subtask_id']).to eq(subtask.id)
      expect(response_data['data']['attributes']['task_sessions_attributes'][0]['task_id']).to eq(task.id)
    end

    it "Returns a 400 (bad request) error with invalid parameters (no workblock field)" do
      badCreateParams = { notworkblock: createParams[:workblock] }
      post '/workblocks', params: badCreateParams.to_json, headers: headers
      expect(response).to have_http_status(:bad_request)
    end

    it "Returns a 401 (unauthorized) error with invalid token" do
      post '/workblocks', params: createParams.to_json, headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /workblocks" do
    let!(:updateParams) { { workblock: { id: workblock.id, completed: true } } }
    let!(:task_session) { FactoryBot.create(:task_session, workblock: workblock, subtask: subtask) }

    it "Returns an updated workblock upon valid request" do
      # Execute basic request to update completed field
      patch '/workblocks', params: updateParams.to_json, headers: headers
      expect(response).to have_http_status(:ok)

      # Make sure the returned object returns correctly changed field
      response_data = JSON.parse(response.body)
      expect(response_data['data']['attributes']['completed']).to be_truthy
    end

    it "Returns an updated workblock upon valid request (remove nested task session)" do
      # Add the _destroy field to the update parameters
      updateParams[:workblock][:task_sessions_attributes] = [ id: task_session.id, _destroy: true ]

      # Execute basic request to update completed field
      patch '/workblocks', params: updateParams.to_json, headers: headers
      expect(response).to have_http_status(:ok)

      # Make sure database reflect the changes
      expect(TaskSession.exists?(task_session.id)).to be false

      # Make sure the returned object returns correctly changed field
      response_data = JSON.parse(response.body)
      expect(response_data['data']['attributes']['completed']).to be_truthy
    end

    it "Returns a 400 (bad request) error with invalid parameters (no nested id field)" do
      badUpdateParams = { workblock: { completed: true } }
      patch '/workblocks', params: badUpdateParams.to_json, headers: headers
      expect(response).to have_http_status(:bad_request)
    end

    it "Returns a 401 (unauthorized) error with invalid token" do
      patch '/workblocks', params: updateParams.to_json, headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "Returns a 404 (not found) error for non-existing workblock" do
      updateParams[:workblock][:id] = 999999
      patch '/workblocks', params: updateParams.to_json, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /workblocks" do
    let!(:destroyParams) { { workblock: { id: workblock.id } } }

    it "Destroys workblock in the database upon valid request" do
      delete '/workblocks', params: destroyParams.to_json, headers: headers
      expect(response).to have_http_status(:ok)
      expect(Workblock.exists?(workblock.id)).to be false
    end

    it "Returns a 401 (unauthorized) error with invalid token" do
      delete '/workblocks', params: destroyParams.to_json, headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "Returns a 404 (not found) error for non-existing workblock" do
      destroyParams[:workblock][:id] = 99999
      delete '/workblocks', params: destroyParams.to_json, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
