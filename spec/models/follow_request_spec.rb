require 'rails_helper'

RSpec.describe FollowRequest, type: :model do
  describe '#authorize!'
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
