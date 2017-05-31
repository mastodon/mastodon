# frozen_string_literal: true

require 'rails_helper'

describe AccountFinderConcern do
  describe '.find_local' do
    before do
      Fabricate(:account, username: 'Alice')
    end

    it 'returns case-insensitive result' do
      expect(Account.find_local('alice')).to_not be_nil
    end

    it 'returns correctly cased result' do
      expect(Account.find_local('Alice')).to_not be_nil
    end

    it 'returns nil without a match' do
      expect(Account.find_local('a_ice')).to be_nil
    end

    it 'returns nil for regex style username value' do
      expect(Account.find_local('al%')).to be_nil
    end
  end

  describe '.find_remote' do
    before do
      Fabricate(:account, username: 'Alice', domain: 'mastodon.social')
    end

    it 'returns exact match result' do
      expect(Account.find_remote('alice', 'mastodon.social')).to_not be_nil
    end

    it 'returns case-insensitive result' do
      expect(Account.find_remote('ALICE', 'MASTODON.SOCIAL')).to_not be_nil
    end

    it 'returns nil when username does not match' do
      expect(Account.find_remote('a_ice', 'mastodon.social')).to be_nil
    end

    it 'returns nil when domain does not match' do
      expect(Account.find_remote('alice', 'm_stodon.social')).to be_nil
    end

    it 'returns nil for regex style domain value' do
      expect(Account.find_remote('alice', 'm%')).to be_nil
    end
  end
end
