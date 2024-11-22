# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Suspensions do
  subject { Fabricate(:account) }

  describe '.suspended' do
    let!(:suspended_account) { Fabricate :account, suspended: true }

    before { Fabricate :account, suspended: false }

    it 'returns accounts that are suspended' do
      expect(Account.suspended)
        .to contain_exactly(suspended_account)
    end
  end

  describe '#suspended_locally?' do
    context 'when the account is not suspended' do
      it { is_expected.to_not be_suspended_locally }
    end

    context 'when the account is suspended locally' do
      before { subject.update!(suspended_at: 1.day.ago, suspension_origin: :local) }

      it { is_expected.to be_suspended_locally }
    end

    context 'when the account is suspended remotely' do
      before { subject.update!(suspended_at: 1.day.ago, suspension_origin: :remote) }

      it { is_expected.to_not be_suspended_locally }
    end
  end

  describe '#suspend!' do
    it 'marks the account as suspended and creates a deletion request' do
      expect { subject.suspend! }
        .to change(subject, :suspended?).from(false).to(true)
        .and change(subject, :suspended_locally?).from(false).to(true)
        .and(change { AccountDeletionRequest.exists?(account: subject) }.from(false).to(true))
    end

    context 'when the account is of a local user' do
      subject { local_user_account }

      let!(:local_user_account) { Fabricate(:user, email: 'foo+bar@domain.org').account }

      it 'creates a canonical domain block' do
        expect { subject.suspend! }
          .to change { CanonicalEmailBlock.block?(subject.user_email) }.from(false).to(true)
      end

      context 'when a canonical domain block already exists for that email' do
        before { Fabricate(:canonical_email_block, email: subject.user_email) }

        it 'does not raise an error' do
          expect { subject.suspend! }
            .to_not raise_error
        end
      end
    end
  end
end
