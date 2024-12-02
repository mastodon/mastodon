# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportSummary do
  subject { described_class.new(account) }

  let(:account) { Fabricate(:account) }
  let(:target_accounts) do
    [
      Fabricate(:account),
      Fabricate(:account, username: 'one', domain: 'local.host'),
    ]
  end

  describe '#total_storage' do
    it 'returns the total size of the media attachments' do
      media_attachment = Fabricate(:media_attachment, account: account)
      expect(subject.total_storage).to eq media_attachment.file_file_size || 0
    end
  end

  describe '#total_statuses' do
    before { Fabricate.times(2, :status, account: account) }

    it 'returns the total number of statuses' do
      expect(subject.total_statuses).to eq(2)
    end
  end

  describe '#total_bookmarks' do
    before { Fabricate.times(2, :bookmark, account: account) }

    it 'returns the total number of bookmarks' do
      expect(subject.total_bookmarks).to eq(2)
    end
  end

  describe '#total_follows' do
    before { target_accounts.each { |target_account| account.follow!(target_account) } }

    it 'returns the total number of the followed accounts' do
      expect(subject.total_follows).to eq(2)
    end
  end

  describe '#total_lists' do
    before { Fabricate.times(2, :list, account: account) }

    it 'returns the total number of lists' do
      expect(subject.total_lists).to eq(2)
    end
  end

  describe '#total_followers' do
    before { target_accounts.each { |target_account| target_account.follow!(account) } }

    it 'returns the total number of the follower accounts' do
      expect(subject.total_followers).to eq(2)
    end
  end

  describe '#total_blocks' do
    before { target_accounts.each { |target_account| account.block!(target_account) } }

    it 'returns the total number of the blocked accounts' do
      expect(subject.total_blocks).to eq(2)
    end
  end

  describe '#total_mutes' do
    before { target_accounts.each { |target_account| account.mute!(target_account) } }

    it 'returns the total number of the muted accounts' do
      expect(subject.total_mutes).to eq(2)
    end
  end

  describe '#total_domain_blocks' do
    before { Fabricate.times(2, :account_domain_block, account: account) }

    it 'returns the total number of account domain blocks' do
      expect(subject.total_domain_blocks).to eq(2)
    end
  end
end
