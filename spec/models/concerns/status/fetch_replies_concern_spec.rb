# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status::FetchRepliesConcern do
  ActiveRecord.verbose_query_logs = true

  let!(:alice)  { Fabricate(:account, username: 'alice') }
  let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'other.com') }

  let!(:account) { alice }
  let!(:status_old) { Fabricate(:status, account: account, fetched_replies_at: 1.year.ago, created_at: 1.year.ago) }
  let!(:status_fetched_recently) { Fabricate(:status, account: account, fetched_replies_at: 1.second.ago, created_at: 1.year.ago) }
  let!(:status_created_recently) { Fabricate(:status, account: account, created_at: 1.second.ago) }
  let!(:status_never_fetched) { Fabricate(:status, account: account, created_at: 1.year.ago) }

  describe 'should_fetch_replies' do
    let!(:statuses) { Status.should_fetch_replies.all }

    context 'with a local status' do
      it 'never fetches local replies' do
        expect(statuses).to eq([])
      end
    end

    context 'with a remote status' do
      let(:account) { bob }

      it 'fetches old statuses' do
        expect(statuses).to include(status_old)
      end

      it 'fetches statuses that have never been fetched and weren\'t created recently' do
        expect(statuses).to include(status_never_fetched)
      end

      it 'does not fetch statuses that were fetched recently' do
        expect(statuses).to_not include(status_fetched_recently)
      end

      it 'does not fetch statuses that were created recently' do
        expect(statuses).to_not include(status_created_recently)
      end
    end
  end

  describe 'should_not_fetch_replies' do
    let!(:statuses) { Status.should_not_fetch_replies.all }

    context 'with a local status' do
      it 'does not fetch local statuses' do
        expect(statuses).to include(status_old, status_never_fetched, status_fetched_recently, status_never_fetched)
      end
    end

    context 'with a remote status' do
      let(:account) { bob }

      it 'fetches old statuses' do
        expect(statuses).to_not include(status_old)
      end

      it 'fetches statuses that have never been fetched and weren\'t created recently' do
        expect(statuses).to_not include(status_never_fetched)
      end

      it 'does not fetch statuses that were fetched recently' do
        expect(statuses).to include(status_fetched_recently)
      end

      it 'does not fetch statuses that were created recently' do
        expect(statuses).to include(status_created_recently)
      end
    end
  end

  describe 'unsubscribed' do
    let!(:spike)  { Fabricate(:account, username: 'spike', domain: 'other.com') }
    let!(:status) { Fabricate(:status, account: bob, updated_at: 1.day.ago) }

    context 'when the status is from an account with only remote followers after last update' do
      before do
        Fabricate(:follow, account: spike, target_account: bob)
      end

      it 'shows the status as unsubscribed' do
        expect(Status.unsubscribed).to eq([status])
      end
    end

    context 'when the status is from an account with only remote followers before last update' do
      before do
        Fabricate(:follow, account: spike, target_account: bob, created_at: 2.days.ago)
      end

      it 'shows the status as unsubscribed' do
        expect(Status.unsubscribed).to eq([status])
      end
    end

    context 'when status is from account with local followers after last update' do
      before do
        Fabricate(:follow, account: alice, target_account: bob)
      end

      it 'shows the status as unsubscribed' do
        expect(Status.unsubscribed).to eq([status])
      end
    end

    context 'when status is from account with local followers before last update' do
      before do
        Fabricate(:follow, account: alice, target_account: bob, created_at: 2.days.ago)
      end

      it 'does not show the status as unsubscribed' do
        expect(Status.unsubscribed).to eq([])
      end
    end

    context 'when the status has no followers' do
      it 'shows the status as unsubscribed' do
        expect(Status.unsubscribed).to eq([status])
      end
    end
  end
end
