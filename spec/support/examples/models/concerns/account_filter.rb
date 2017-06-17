require 'rails_helper'

shared_examples 'AccountFilter' do |fabricator|
  describe 'with empty params' do
    it 'defaults to alphabetic account list' do
      expect(described_class.filter({})).to eq described_class.alphabetic
    end
  end

  describe 'with invalid params' do
    it 'raises with key error' do
      expect { described_class.filter(wrong: true) }.to raise_error(/wrong/)
    end
  end

  describe 'with valid params' do
    it 'combines filters on Account' do
      account = Fabricate(fabricator, domain: 'test.com', silenced: true, username: 'test', display_name: 'name')
      Fabricate(:user, account: account, email: 'user@example.com', current_sign_in_ip: '127.0.0.1')

      filtered = described_class.filter(
        by_domain: 'test.com',
        silenced: true,
        username: 'test',
        display_name: 'name',
        email: 'user@example.com',
        ip: '127.0.0.1',
      )

      expect(filtered).to eq [account]
    end

    describe 'that call account methods' do
      %i(local remote silenced recent suspended).each do |option|
        it "delegates the #{option} option" do
          allow(described_class).to receive(option).and_return(described_class.none)
          described_class.filter({ option => true })

          expect(described_class).to have_received(option)
        end
      end
    end
  end
end
