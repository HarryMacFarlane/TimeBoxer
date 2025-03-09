# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    user = FactoryBot.build(:user)
    expect(user).to be_valid
  end

  it 'is invalid without an email' do
    user = FactoryBot.build(:user, email: nil)
    expect(user).to_not be_valid
  end

  it 'is invalid with a duplicate email' do
    user1 = FactoryBot.create(:user, email: 'test@example.com')
    user2 = FactoryBot.build(:user, email: 'test@example.com')
    expect(user2).to_not be_valid
  end
end
