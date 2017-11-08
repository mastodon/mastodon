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

  describe 'validations' do
    it 'has a valid fabricator' do
      follow_request = Fabricate.build(:follow_request)
      expect(follow_request).to be_valid
    end

    it 'is invalid without an account' do
      follow_request = Fabricate.build(:follow_request, account: nil)
      follow_request.valid?
      expect(follow_request).to model_have_error_on_field(:account)
    end

    it 'is invalid without a target account' do
      follow_request = Fabricate.build(:follow_request, target_account: nil)
      follow_request.valid?
      expect(follow_request).to model_have_error_on_field(:target_account)      
    end
  end
end
