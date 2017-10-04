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
    it 'filters remote account' do
      account = Fabricate(fabricator, domain: nil)
      Fabricate(fabricator, domain: Faker::Internet.domain_name)

      filtered = described_class.filter(local: true)

      expect(filtered).to eq [account]
    end

    it 'filters local account' do
      account = Fabricate(fabricator, domain: Faker::Internet.domain_name)
      Fabricate(fabricator, domain: nil)

      filtered = described_class.filter(remote: true)

      expect(filtered).to eq [account]
    end

    it 'filters by domain' do
      account = Fabricate(fabricator, domain: 'matching')
      Fabricate(fabricator, domain: 'unmatching')

      filtered = described_class.filter(by_domain: 'matching')

      expect(filtered).to eq [account]
    end

    it 'filters by silenced' do
      account = Fabricate(fabricator, silenced: true)
      Fabricate(fabricator, silenced: false)

      filtered = described_class.filter(silenced: true)

      expect(filtered).to eq [account]
    end

    it 'reorders by recent creation' do
      accounts = 2.times.map { Fabricate(fabricator) }
      filtered = described_class.filter(recent: true)
      expect(filtered).to eq accounts.reverse
    end

    it 'filteres by suspended' do
      account = Fabricate(fabricator, suspended: true)
      Fabricate(fabricator, suspended: false)

      filtered = described_class.filter(suspended: true)

      expect(filtered).to eq [account]
    end

    it 'filteres by username' do
      account = Fabricate(fabricator, username: 'matching')
      Fabricate(fabricator, username: 'unmatching')

      filtered = described_class.filter(username: 'matching')

      expect(filtered).to eq [account]
    end

    it 'filters by email' do
      match = Fabricate(fabricator)
      Fabricate(:user, account: match, email: 'matching@example.com')
      unmatch = Fabricate(fabricator)
      Fabricate(:user, account: unmatch, email: 'unmatching@example.com')

      filtered = described_class.filter(email: 'matching@example.com')

      expect(filtered).to eq [match]
    end

    it 'filters by ip' do
      match = Fabricate(fabricator)
      Fabricate(:user, account: match, last_sign_in_ip: '127.0.0.1')
      unmatch = Fabricate(fabricator)
      Fabricate(:user, account: unmatch, current_sign_in_ip: nil, last_sign_in_ip: nil)

      filtered = described_class.filter(ip: '127.0.0.1')

      expect(filtered).to eq [match]
    end

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
  end
end
