module AuthenticationHelper
  def sign_in_user(user)
    post '/login', params: { email: user.email, password: user.password }, headers: {'ACCEPT' => 'application/json'}
    response.headers['Authorization'].split(" ").last
  end
end


RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end