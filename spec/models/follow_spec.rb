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

  describe '#local?' do
    it { is_expected.to_not be_local }
  end

  describe 'Callbacks' do
    describe 'Setting a URI' do
      context 'when URI exists' do
        subject { Fabricate.build :follow, uri: 'https://uri/value' }

        it 'does not change' do
          expect { subject.save }
            .to not_change(subject, :uri)
        end
      end

      context 'when URI is blank' do
        subject { Fabricate.build :follow, uri: nil }

        it 'populates the value' do
          expect { subject.save }
            .to change(subject, :uri).to(be_present)
        end
      end
    end

    describe 'Maintaining counters' do
      subject { Fabricate.build :follow, account:, target_account: }

      let(:account) { Fabricate :account }
      let(:target_account) { Fabricate :account }

      before do
        account.account_stat.update following_count: 123
        target_account.account_stat.update followers_count: 123
      end

      describe 'saving the follow' do
        it 'increments counters' do
          expect { subject.save }
            .to change(account, :following_count).by(1)
            .and(change(target_account, :followers_count).by(1))
        end
      end

      describe 'destroying the follow' do
        it 'decrements counters' do
          expect { subject.destroy }
            .to change(account, :following_count).by(-1)
            .and(change(target_account, :followers_count).by(-1))
        end
      end
    end
  end
end
