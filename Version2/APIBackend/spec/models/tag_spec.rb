require 'rails_helper'

RSpec.describe Tag, type: :model do
  let!(:user) { FactoryBot.create(:user) }

  it 'is valid with valid attributes' do
    tag = FactoryBot.build(:tag, user: user)
    expect(tag).to be_valid
  end

  it 'is invalid without a name' do
    tag = FactoryBot.build(:tag, tag_name: nil, user: user)
    expect(tag).to_not be_valid
  end

  it 'is invalid with a duplicate tag name (for same user)' do
    tag1 = FactoryBot.create(:tag, tag_name: 'ex1', user: user)
    tag2 = FactoryBot.build(:tag, tag_name: 'ex1', user: user)
    expect(tag2).to_not be_valid
  end
end
