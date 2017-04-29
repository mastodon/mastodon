require 'rails_helper'

describe AccountFilter do
  describe 'with empty params' do
    it 'defaults to alphabetic account list' do
      filter = AccountFilter.new({})

      expect(filter.results).to eq Account.alphabetic
    end
  end

  describe 'with invalid params' do
    it 'raises with key error' do
      filter = AccountFilter.new(wrong: true)

      expect { filter.results }.to raise_error(/wrong/)
    end
  end

  describe 'with valid params' do
    it 'combines filters on Account' do
      filter = AccountFilter.new(by_domain: 'test.com', silenced: true)

      allow(Account).to receive(:where).and_return(Account.none)
      allow(Account).to receive(:silenced).and_return(Account.none)
      filter.results
      expect(Account).to have_received(:where).with(domain: 'test.com')
      expect(Account).to have_received(:silenced)
    end
  end
end
