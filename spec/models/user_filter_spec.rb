require 'rails_helper'

describe UserFilter do
  describe 'with empty params' do
    it 'defaults to alphabetic user list' do
      filter = UserFilter.new({})

      expect(filter.results).to eq User.all
    end
  end

  describe 'with invalid params' do
    it 'raises with key error' do
      filter = UserFilter.new(wrong: true)

      expect { filter.results }.to raise_error(/wrong/)
    end
  end

  describe 'with valid params' do
    it 'combines filters on User' do
      filter = UserFilter.new(admin: true, unconfirmed: true)

      allow(User).to receive(:admins).and_return(User.none)
      allow(User).to receive(:unconfirmed).and_return(User.none)
      filter.results
      expect(User).to have_received(:admins)
      expect(User).to have_received(:unconfirmed)
    end
  end
end
