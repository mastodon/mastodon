require 'rails_helper'

RSpec.describe Follow, type: :model do
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob') }

  describe 'validations' do
    subject { Follow.new(account: alice, target_account: bob, rate_limit: true) }

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

    it 'is invalid if account already follows too many people' do
      alice.update(following_count: FollowLimitValidator::LIMIT)

      expect(subject).to_not be_valid
      expect(subject).to model_have_error_on_field(:base)
    end

    it 'is valid if account is only on the brink of following too many people' do
      alice.update(following_count: FollowLimitValidator::LIMIT - 1)

      expect(subject).to be_valid
      expect(subject).to_not model_have_error_on_field(:base)
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

  describe 'revoke_request!' do
    let(:follow)         { Fabricate(:follow, account: account, target_account: target_account) }
    let(:account)        { Fabricate(:account) }
    let(:target_account) { Fabricate(:account) }

    it 'revokes the follow relation' do
      follow.revoke_request!
      expect(account.following?(target_account)).to be false
    end

    it 'creates a follow request' do
      follow.revoke_request!
      expect(account.requested?(target_account)).to be true
    end
  end
end
