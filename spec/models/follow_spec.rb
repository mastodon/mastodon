require 'rails_helper'

RSpec.describe Follow, type: :model do
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob') }

  subject { Follow.new(account: alice, target_account: bob) }

  describe 'validations' do
    it 'has a valid fabricator' do
      follow = Fabricate.build(:follow)
      expect(follow).to be_valid
    end

    it 'is invalid without an account' do
      follow = Fabricate.build(:follow, account: nil)
      follow.valid?
      expect(follow).to model_have_error_on_field(:account)
    end

    it 'is invalid without a target_account' do
      follow = Fabricate.build(:follow, target_account: nil)
      follow.valid?
      expect(follow).to model_have_error_on_field(:target_account)
    end
  end
end
