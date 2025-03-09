require 'rails_helper'

RSpec.describe "Subjects API", type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:subject) { FactoryBot.create(:subject, user: user) }

  let!(:headers) do
    post '/login', params: { user: { email: user.email, password: user.password } }, headers: { 'ACCEPT' => 'application/json' }
    token = response.headers['Authorization'].split(" ").last
    { 'Content-Type'=> 'application/json', 'Authorization' => "Bearer #{token}" }
  end

  let(:bad_headers) do
    { 'Content-Type'=> 'application/json', 'Authorization' => "Bearer deaniilfaefjiaedp120d13" }
  end

  let!(:basicSubjectParams) { { subject: { name: subject.name, description: subject.description } } }

  describe "GET /subjects:" do
    it "Does not raise an error for a correct request" do
      get '/subjects', headers: headers
      expect(response).to have_http_status(:ok)
    end

    it 'Raises a 401 error with invalid token' do
      get '/subjects', headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /subjects/:id" do
    let!(:showRoute) { "/subjects/#{subject.id}" }
    it "Returns the correct subject when provided with the name" do
      get showRoute, headers: headers
      expect(response).to have_http_status(:ok)
      response_data = JSON.parse(response.body)
      expect(response_data['data']['id']).to eq(subject.id.to_s)
      expect(response_data['data']['attributes']['name']).to eq("Test Subject")
      expect(response_data['data']['attributes']['description']).to eq("Test description")
    end

    it 'Returns 404 error if the subject does not exist (could not be found)' do
      get "/subjects/99999", headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'Returns a 401 error if jwt token is invalid' do
      get showRoute, headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /subjects" do
    it 'Creates a new subject upon a correct request' do
      newSubject = { subject: { name: 'New Test Subject', description: 'New test description' } }
      post '/subjects', params: newSubject.to_json, headers: headers
      response_data = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(response_data['data']['attributes']['name']).to eq("New Test Subject")
      expect(response_data['data']['attributes']['description']).to eq("New test description")
    end

    it 'Raises a 404 (unprocessable_entity) error if the subject already exists' do
      post '/subjects', params: basicSubjectParams.to_json, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'Raises a 401 (unauthorized) error if the token is not valid' do
      newSubject = { subject: { name: 'New Test Subject', description: 'New test description' } }
      post '/subjects', params: newSubject.to_json, headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
  describe "PATCH /subjects" do
    let!(:updateParams) { { subject: { id: subject.id, name: subject.name, description: 'New description' } } }
    it 'Updates the description of a subject with valid request' do
      patch '/subjects', params: updateParams.to_json, headers: headers
      expect(response).to have_http_status(:ok)
      subject.reload
      expect(subject.description).to eq("New description")

      # Verify the response data
      response_data = JSON.parse(response.body)
      expect(response_data['data']['id']).to eq(subject.id.to_s)
      expect(response_data['data']['attributes']['description']).to eq(subject.description)
    end

    it "Updates the name of a subject with valid request" do
      updateParams[:subject][:name] = "New Subject Name"

      # Execute the request and verify status code
      patch '/subjects', params: updateParams.to_json, headers: headers
      expect(response).to have_http_status(:ok)

      # Check database
      subject.reload
      expect(subject.name).to eq("New Subject Name")

      # Verify the response data
      response_data = JSON.parse(response.body)
      expect(response_data['data']['id']).to eq(subject.id.to_s)
      expect(response_data['data']['attributes']['description']).to eq(subject.description)
    end

    it "Returns a 401 error with invalid token" do
      patch '/subjects', params: updateParams.to_json, headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "Returns a 404 (not found) error with a non-existent subject patch" do
      # Since the subject is created for each user, we need to create a name we know doesn't exist, such as the name with a 1 appended
      updateParams[:subject][:id] = 999999
      patch '/subjects', params: updateParams.to_json, headers: headers
      expect(response).to have_http_status(:not_found)
    end

    # MAKE SURE TO FINISH THIS TEST (although it is by far the least needed as the frontend will likely take care of it)
    it "Returns a 422 (unprocessable_entity) error when trying to assign a new name that exists elsewhere" do
      # Create new subject
      user.reload
      new_subject = user.subjects.create!({ name: "#{subject.name}2", description: 'Second test description' })
      new_subject.reload
      expect(new_subject).not_to be_nil
      # Add new subject name to update parameters
      updateParams[:subject][:name] = "#{subject.name}2"
      patch '/subjects', params: updateParams.to_json, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /subjects" do
    let!(:deleteParams) { { subject: { id: subject.id } } }
    it "Deletes the subject with valid request" do
      # Make sure the subject was correctly created
      expect(Subject.exists?(subject.id)).to be true
      # Execute the request and verify the status code
      delete '/subjects', params: deleteParams.to_json, headers: headers
      expect(response).to have_http_status(:ok)

      # Ensure the entry was been deleted from the database
      expect(Subject.exists?(subject.id)).to be false
    end

    it 'Returns a 401 (unauthorized) error with invalid token' do
      delete '/subjects', params: deleteParams.to_json, headers: bad_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "Returns a 404 (not found) error when the subject doesn't exist" do
      # Create parameters for the request
      deleteParams[:subject][:id] = 99999
      # Execute the request and verify the status code
      delete '/subjects', params: deleteParams.to_json, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
