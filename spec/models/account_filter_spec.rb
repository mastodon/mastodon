require 'rails_helper'

describe AccountFilter do
  describe 'with empty params' do
    it 'defaults to recent local not-suspended account list' do
      filter = described_class.new({})

      expect(filter.results).to eq Account.local.recent.without_suspended
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
      filter = described_class.new(
        by_domain: 'test.com',
        silenced: true,
        username: 'test',
        display_name: 'name',
        email: 'user@example.com',
      )

      allow(Account).to receive(:where).and_return(Account.none)
      allow(Account).to receive(:silenced).and_return(Account.none)
      allow(Account).to receive(:matches_display_name).and_return(Account.none)
      allow(Account).to receive(:matches_username).and_return(Account.none)
      allow(User).to receive(:matches_email).and_return(User.none)

      filter.results

      expect(Account).to have_received(:where).with(domain: 'test.com')
      expect(Account).to have_received(:silenced)
      expect(Account).to have_received(:matches_username).with('test')
      expect(Account).to have_received(:matches_display_name).with('name')
      expect(User).to have_received(:matches_email).with('user@example.com')
    end

    describe 'that call account methods' do
      %i(local remote silenced suspended).each do |option|
        it "delegates the #{option} option" do
          allow(Account).to receive(option).and_return(Account.none)
          filter = described_class.new({ option => true })
          filter.results

          expect(Account).to have_received(option).at_least(1)
        end
      end
    end
  end
end
