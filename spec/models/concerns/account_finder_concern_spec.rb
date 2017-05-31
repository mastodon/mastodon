# frozen_string_literal: true

require 'rails_helper'

describe AccountFinderConcern do
  describe '.find_local' do
    before do
      Fabricate(:account, username: 'Alice')
    end

    it 'returns Alice for alice' do
      expect(Account.find_local('alice')).to_not be_nil
    end

    it 'returns Alice for Alice' do
      expect(Account.find_local('Alice')).to_not be_nil
    end

    it 'does not return anything for a_ice' do
      expect(Account.find_local('a_ice')).to be_nil
    end

    it 'does not return anything for al%' do
      expect(Account.find_local('al%')).to be_nil
    end
  end

  describe '.find_remote' do
    before do
      Fabricate(:account, username: 'Alice', domain: 'mastodon.social')
    end

    it 'returns Alice for alice@mastodon.social' do
      expect(Account.find_remote('alice', 'mastodon.social')).to_not be_nil
    end

    it 'returns Alice for ALICE@MASTODON.SOCIAL' do
      expect(Account.find_remote('ALICE', 'MASTODON.SOCIAL')).to_not be_nil
    end

    it 'does not return anything for a_ice@mastodon.social' do
      expect(Account.find_remote('a_ice', 'mastodon.social')).to be_nil
    end

    it 'does not return anything for alice@m_stodon.social' do
      expect(Account.find_remote('alice', 'm_stodon.social')).to be_nil
    end

    it 'does not return anything for alice@m%' do
      expect(Account.find_remote('alice', 'm%')).to be_nil
    end
  end
end
