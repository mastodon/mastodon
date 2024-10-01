# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Export do
  let(:account) { Fabricate(:account) }
  let(:target_accounts) do
    [{}, { username: 'one', domain: 'local.host' }].map(&method(:Fabricate).curry(2).call(:account))
  end

  describe 'to_csv' do
    it 'returns a csv of the blocked accounts' do
      target_accounts.each { |target_account| account.block!(target_account) }

      export = described_class.new(account).to_blocked_accounts_csv
      results = export.strip.split

      expect(results.size).to eq 2
      expect(results.first).to eq 'one@local.host'
    end

    it 'returns a csv of the muted accounts' do
      target_accounts.each { |target_account| account.mute!(target_account) }

      export = described_class.new(account).to_muted_accounts_csv
      results = export.strip.split("\n")

      expect(results.size).to eq 3
      expect(results.first).to eq 'Account address,Hide notifications'
      expect(results.second).to eq 'one@local.host,true'
    end

    it 'returns a csv of the following accounts' do
      target_accounts.each { |target_account| account.follow!(target_account) }

      export = described_class.new(account).to_following_accounts_csv
      results = export.strip.split("\n")

      expect(results.size).to eq 3
      expect(results.first).to eq 'Account address,Show boosts,Notify on new posts,Languages'
      expect(results.second).to eq 'one@local.host,true,false,'
    end
  end

  describe 'total_storage' do
    it 'returns the total size of the media attachments' do
      media_attachment = Fabricate(:media_attachment, account: account)
      expect(described_class.new(account).total_storage).to eq media_attachment.file_file_size || 0
    end
  end

  describe 'total_follows' do
    it 'returns the total number of the followed accounts' do
      target_accounts.each { |target_account| account.follow!(target_account) }
      expect(described_class.new(account.reload).total_follows).to eq 2
    end

    it 'returns the total number of the blocked accounts' do
      target_accounts.each { |target_account| account.block!(target_account) }
      expect(described_class.new(account.reload).total_blocks).to eq 2
    end

    it 'returns the total number of the muted accounts' do
      target_accounts.each { |target_account| account.mute!(target_account) }
      expect(described_class.new(account.reload).total_mutes).to eq 2
    end
  end
end
