require 'rails_helper'

RSpec.describe FollowRequest, type: :model do
  describe '#authorize!' do
    let(:follow_request) { Fabricate(:follow_request, account: account, target_account: target_account) }
    let(:account)        { Fabricate(:account) }
    let(:target_account) { Fabricate(:account) }

    it 'calls Account#follow!, MergeWorker.perform_async, and #destroy!' do
      expect(account).to        receive(:follow!).with(target_account)
      expect(MergeWorker).to    receive(:perform_async).with(target_account.id, account.id)
      expect(follow_request).to receive(:destroy!)
      follow_request.authorize!
    end
  end
end
