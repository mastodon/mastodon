require 'rails_helper'

describe AccountFilter do
  describe 'with empty params' do
    it 'defaults to alphabetic account list' do
      filter = described_class.new({})

      expect(filter.results).to eq Account.alphabetic
    end
  end

  describe 'with invalid params' do
    it 'raises with key error' do
      filter = described_class.new(wrong: true)

      expect { filter.results }.to raise_error(/wrong/)
    end
  end

  describe 'with valid params' do
    it 'combines filters on Account' do
      filter = described_class.new(by_domain: 'test.com', silenced: true)

      allow(Account).to receive(:where).and_return(Account.none)
      allow(Account).to receive(:silenced).and_return(Account.none)
      filter.results
      expect(Account).to have_received(:where).with(domain: 'test.com')
      expect(Account).to have_received(:silenced)
    end

    describe 'that call account methods' do
      %i(local remote silenced recent).each do |option|
        it "delegates the #{option} option" do
          allow(Account).to receive(option).and_return(Account.none)
          filter = described_class.new({ option => true })
          filter.results

          expect(Account).to have_received(option)
        end
      end
    end
  end
end
