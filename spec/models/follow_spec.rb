require 'rails_helper'

RSpec.describe Follow, type: :model do
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob') }

  describe 'validations' do
    subject { Follow.new(account: alice, target_account: bob) }

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

  describe 'recent' do
    it 'sorts so that more recent follows comes earlier' do
      follow0 = Follow.create!(account: alice, target_account: bob)
      follow1 = Follow.create!(account: bob, target_account: alice)

      a = Follow.recent.to_a

      expect(a.size).to eq 2
      expect(a[0]).to eq follow1
      expect(a[1]).to eq follow0
    end
  end
end
