# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Follow do
  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to belong_to(:target_account).required }
  end

  describe 'Validations' do
    subject { Fabricate.build :follow, rate_limit: true }

    let(:account) { Fabricate(:account) }

    context 'when account follows too many people' do
      before { account.update(following_count: FollowLimitValidator::LIMIT) }

      it { is_expected.to_not allow_value(account).for(:account).against(:base) }
    end

    context 'when account is on brink of following too many people' do
      before { account.update(following_count: FollowLimitValidator::LIMIT - 1) }

      it { is_expected.to allow_value(account).for(:account).against(:base) }
    end
  end

  describe '.recent' do
    let!(:follow_earlier) { Fabricate(:follow) }
    let!(:follow_later) { Fabricate(:follow) }

    it 'sorts with most recent follows first' do
      results = described_class.recent

      expect(results.size).to eq 2
      expect(results).to eq [follow_later, follow_earlier]
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
