# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountsHelper do
  describe '#display_name' do
    it 'uses the display name when it exists' do
      account = Account.new(display_name: 'Display', username: 'Username')

      expect(helper.display_name(account)).to eq 'Display'
    end

    it 'uses the username when display name is nil' do
      account = Account.new(display_name: nil, username: 'Username')

      expect(helper.display_name(account)).to eq 'Username'
    end
  end

  describe '#acct' do
    it 'is fully qualified for local accounts' do
      allow(Rails.configuration.x).to receive(:local_domain).and_return('local_domain')
      account = Account.new(domain: nil, username: 'user')

      acct = helper.acct(account)

      expect(acct).to eq '@user@local_domain'
    end

    it 'is fully qualified for remote accounts' do
      account = Account.new(domain: 'foreign_server.com', username: 'user')

      acct = helper.acct(account)

      expect(acct).to eq '@user@foreign_server.com'
    end
  end
end
