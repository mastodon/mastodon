require 'rails_helper'

RSpec.describe FollowRequest, type: :model do
  describe '#authorize!' do
    let(:follow_request) { Fabricate(:follow_request, account: account, target_account: target_account) }
    let(:account)        { Fabricate(:account) }
    let(:target_account) { Fabricate(:account) }

    it 'calls Account#follow!, MergeWorker.perform_async, and #destroy!' do
      expect(account).to        receive(:follow!).with(target_account, reblogs: true, notify: false, uri: follow_request.uri)
      expect(MergeWorker).to    receive(:perform_async).with(target_account.id, account.id)
      expect(follow_request).to receive(:destroy!)
      follow_request.authorize!
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
end
