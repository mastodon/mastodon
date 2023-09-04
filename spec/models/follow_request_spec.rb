# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FollowRequest do
  describe '#authorize!' do
    let!(:follow_request) { Fabricate(:follow_request, account: account, target_account: target_account) }
    let(:account)         { Fabricate(:account) }
    let(:target_account)  { Fabricate(:account) }

    context 'when the to-be-followed person has been added to a list' do
      let!(:list) { Fabricate(:list, account: account) }

      before do
        list.accounts << target_account
      end

      it 'updates the ListAccount' do
        expect { follow_request.authorize! }.to change { [list.list_accounts.first.follow_request_id, list.list_accounts.first.follow_id] }.from([follow_request.id, nil]).to([nil, anything])
      end
    end

    it 'calls Account#follow!, MergeWorker.perform_async, and #destroy!' do
      expect(account).to receive(:follow!).with(target_account, reblogs: true, notify: false, uri: follow_request.uri, languages: nil, bypass_limit: true) do
        account.active_relationships.create!(target_account: target_account)
      end
      expect(MergeWorker).to receive(:perform_async).with(target_account.id, account.id)
      expect(follow_request).to receive(:destroy!)
      follow_request.authorize!
    end

    it 'generates a Follow' do
      follow_request = Fabricate.create(:follow_request)
      follow_request.authorize!
      target = follow_request.target_account
      expect(follow_request.account.following?(target)).to be true
    end

    it 'correctly passes show_reblogs when true' do
      follow_request = Fabricate.create(:follow_request, show_reblogs: true)
      follow_request.authorize!
      target = follow_request.target_account
      expect(follow_request.account.muting_reblogs?(target)).to be false
    end

    it 'correctly passes show_reblogs when false' do
      follow_request = Fabricate.create(:follow_request, show_reblogs: false)
      follow_request.authorize!
      target = follow_request.target_account
      expect(follow_request.account.muting_reblogs?(target)).to be true
    end
  end

  describe '#reject!' do
    let!(:follow_request) { Fabricate(:follow_request, account: account, target_account: target_account) }
    let(:account)         { Fabricate(:account) }
    let(:target_account)  { Fabricate(:account) }

    context 'when the to-be-followed person has been added to a list' do
      let!(:list) { Fabricate(:list, account: account) }

      before do
        list.accounts << target_account
      end

      it 'deletes the ListAccount record' do
        expect { follow_request.reject! }.to change { list.accounts.count }.from(1).to(0)
      end
    end
  end
end
