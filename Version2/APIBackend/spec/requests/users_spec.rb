require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  describe 'POST /signup' do
    it 'creates a new user under normal circumstances' do
      headers = { 'ACCEPT' => 'application/json' }
      post '/signup', params: { user: { email: 'john@example.com', password: 'password', password_confirmation: 'password' } }, headers: headers
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['data']['email']).to eq('john@example.com')
    end

    it 'creates a new user when password confirmation is missing' do
      headers = { 'ACCEPT' => 'application/json' }
      post '/signup', params: { user: { email: 'john@example.com', password: 'password' } }, headers: headers
      expect(response).to have_http_status(:created)
    end

    it "returns a JWT token in the Authorization header" do
      headers = { 'ACCEPT' => 'application/json' }
      post '/signup', params: { user: { email: 'john@example.com', password: 'password', password_confirmation: 'password' } }, headers: headers

      expect(response).to have_http_status(:created)
      expect(response.headers["Authorization"]).to be_present
      expect(response.headers["Authorization"]).to match(/^Bearer /)

      token = response.headers["Authorization"]
      expect(token).to be_present
    end


    it 'returns an error if email is missing' do
      post '/signup', params: { user: { password: 'password', password_confirmation: 'password' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']).to eq("Email can't be blank")
    end

    it 'returns an error if password is missing' do
      post '/signup', params: { user: { email: 'john@example.com' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']).to eq("Password can't be blank")
    end

    it 'returns an error if password is missing but password_confirmation is not' do
      post '/signup', params: { user: { email: 'john@example.com', password_confirmation: 'password' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']).to eq("Password can't be blank and Password confirmation doesn't match Password")
    end
  end

  describe "POST /signin" do
    let(:headers) { { 'ACCEPT' => 'application/json' } }
    it 'returns a JWT token upon successful sign-in' do
      post '/login', params: { user: { email: user.email, password: user.password, password_confirmation: user.password } }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to be_present
      expect(response.headers["Authorization"]).to match(/^Bearer /)

      token = response.headers["Authorization"]
      expect(token).to be_present
    end

    it 'returns an error if the password is not provided' do
      post '/login', params: { user: { email: user.email, password_confirmation: "password" } }, headers: headers
      expect(response).to have_http_status(:unauthorized)

      response_data = JSON.parse(response.body)
      expect(response_data['error']).to eq("Invalid Email or password.")
    end

    it 'returns an error if the email is not provided' do
      post '/login', params: { user: { password: 'password', password_confirmation: "password" } }, headers: headers
      expect(response).to have_http_status(:unauthorized)

      response_data = JSON.parse(response.body)
      expect(response_data['error']).to eq("You need to sign in or sign up before continuing.")
    end

    it 'returns an error if the user does not exist' do
      post '/login', params: { user: { email: 'iamaghost@noone.com', password: "password" } }, headers: headers
      expect(response).to have_http_status(:unauthorized)
      response_data = JSON.parse(response.body)
      expect(response_data['error']).to eq("Invalid Email or password.")
    end
  end

  describe "DELETE /signout" do
    before (:each) {
      post '/login', params: { user: { email: user.email, password: user.password } }, headers: { 'ACCEPT' => 'application/json' }
      token = response.headers['Authorization'].split(" ").last
      @headers = { 'Content-Type'=> 'application/json', 'Authorization' => "Bearer #{token}" }
    }

    it 'checks that JWT token can be successfully decoded' do
      jwt_payload = JWT.decode(headers['Authorization'].split(" ").last, Rails.application.credentials.devise_jwt_secret_key!).first
      current_user = User.find(jwt_payload['sub'])
      expect(current_user).not_to be_nil
    end

    it 'signs out user upon valid request' do
      old_jti = user.jti
      delete '/logout', headers: @headers
      expect(response).to have_http_status(:ok)
      user.reload
      expect(user.jti).not_to eq(old_jti)
    end

    it 'fails signout without a valid token' do
      delete '/logout', params: { user: { email: user.email, password: user.password } }, headers: { 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
