# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Export do
  subject { described_class.new(account) }

  let(:account) { Fabricate(:account) }
  let(:target_accounts) do
    [
      Fabricate(:account),
      Fabricate(:account, username: 'one', domain: 'local.host'),
    ]
  end

  describe '#to_bookmarks_csv' do
    let!(:bookmark) { Fabricate(:bookmark, account: account) }
    let(:export) { CSV.parse(subject.to_bookmarks_csv) }
    let!(:second_bookmark) { Fabricate(:bookmark, account: account) }
    let!(:bookmark_of_soft_deleted) { Fabricate(:bookmark, account: account) }

    before do
      bookmark_of_soft_deleted.status.discard
    end

    it 'returns a csv of bookmarks' do
      expect(export)
        .to contain_exactly(
          [ActivityPub::TagManager.instance.uri_for(bookmark.status)],
          [ActivityPub::TagManager.instance.uri_for(second_bookmark.status)]
        )
    end
  end

  describe '#to_blocked_accounts_csv' do
    before { target_accounts.each { |target_account| account.block!(target_account) } }

    let(:export) { CSV.parse(subject.to_blocked_accounts_csv) }

    it 'returns a csv of the blocked accounts' do
      expect(export)
        .to contain_exactly(
          include('one@local.host'),
          include(be_present)
        )
    end
  end

  describe '#to_muted_accounts_csv' do
    before { target_accounts.each { |target_account| account.mute!(target_account) } }

    let(:export) { CSV.parse(subject.to_muted_accounts_csv) }

    it 'returns a csv of the muted accounts' do
      expect(export)
        .to contain_exactly(
          contain_exactly('Account address', 'Hide notifications'),
          include('one@local.host', 'true'),
          include(be_present)
        )
    end
  end

  describe '#to_following_accounts_csv' do
    before { target_accounts.each { |target_account| account.follow!(target_account) } }

    let(:export) { CSV.parse(subject.to_following_accounts_csv) }

    it 'returns a csv of the following accounts' do
      expect(export)
        .to contain_exactly(
          contain_exactly('Account address', 'Show boosts', 'Notify on new posts', 'Languages'),
          include('one@local.host', 'true', 'false', be_blank),
          include(be_present)
        )
    end
  end

  describe '#to_lists_csv' do
    before do
      target_accounts.each do |target_account|
        account.follow!(target_account)
        Fabricate(:list, account: account).accounts << target_account
      end
    end

    let(:export) { CSV.parse(subject.to_lists_csv) }

    it 'returns a csv of the lists' do
      expect(export)
        .to contain_exactly(
          include('one@local.host'),
          include(be_present)
        )
    end
  end

  describe '#to_blocked_domains_csv' do
    before { Fabricate.times(2, :account_domain_block, account: account) }

    let(:export) { CSV.parse(subject.to_blocked_domains_csv) }

    it 'returns a csv of the blocked domains' do
      expect(export)
        .to contain_exactly(
          include(/example/),
          include(/example/)
        )
    end
  end
end
