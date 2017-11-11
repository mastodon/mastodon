require 'rails_helper'

RSpec.describe FollowRequest, type: :model do
  describe '#authorize!' do
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

  describe '#reject!'

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
