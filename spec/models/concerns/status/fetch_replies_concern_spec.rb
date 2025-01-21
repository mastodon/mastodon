# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status::FetchRepliesConcern do
  ActiveRecord.verbose_query_logs = true

  describe 'unsubscribed' do
    let!(:alice)  { Fabricate(:account, username: 'alice') }
    let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'other.com') }
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
