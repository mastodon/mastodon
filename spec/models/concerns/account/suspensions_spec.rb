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

      context 'when a canonical domain block for that email is created concurrently' do
        before do
          Fabricate(:canonical_email_block, email: subject.user_email)

          # Simulate another suspension committing a block for the same e-mail
          # after the uniqueness validation has passed, so that the insert
          # hits the unique index
          allow(CanonicalEmailBlock).to receive(:create) do |attributes|
            CanonicalEmailBlock.new(attributes).save!(validate: false)
          end
        end

        it 'suspends the account without aborting the enclosing transaction' do
          expect { ApplicationRecord.transaction { subject.suspend! } }
            .to_not raise_error

          expect(subject.reload)
            .to be_suspended_locally
          expect(CanonicalEmailBlock.where(reference_account: subject))
            .to_not exist
        end
      end
    end
  end
end
