# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'User::Confirmation' do
  describe 'Scopes' do
    let!(:unconfirmed_user) { Fabricate :user, confirmed_at: nil }
    let!(:confirmed_user) { Fabricate :user, confirmed_at: Time.now.utc }

    describe '.confirmed' do
      it 'returns users who are confirmed' do
        expect(described_class.confirmed)
          .to contain_exactly(confirmed_user)
      end
    end

    describe '.unconfirmed' do
      it 'returns users who are not confirmed' do
        expect(described_class.unconfirmed)
          .to contain_exactly(unconfirmed_user)
      end
    end
  end

  describe '#confirmed?' do
    subject { Fabricate.build(:user, confirmed_at:) }

    context 'when confirmed_at is set' do
      let(:confirmed_at) { Time.now.utc }

      it { is_expected.to be_confirmed }
    end

    context 'when confirmed_at is not set' do
      let(:confirmed_at) { nil }

      it { is_expected.to_not be_confirmed }
    end
  end

  describe '#unconfirmed?' do
    subject { Fabricate.build(:user, confirmed_at:) }

    context 'when confirmed_at is set' do
      let(:confirmed_at) { Time.now.utc }

      it { is_expected.to_not be_unconfirmed }
    end

    context 'when confirmed_at is not set' do
      let(:confirmed_at) { nil }

      it { is_expected.to be_unconfirmed }
    end
  end

  describe '#confirm' do
    subject { user.confirm }

    let(:new_email) { 'new-email@host.example' }

    before { allow(TriggerWebhookWorker).to receive(:perform_async) }

    context 'when the user is already confirmed' do
      let!(:user) { Fabricate(:user, confirmed_at: Time.now.utc, approved: true, unconfirmed_email: new_email) }

      it 'sets email to unconfirmed_email and does not trigger web hook' do
        expect { subject }
          .to change { user.reload.email }.to(new_email)
        expect(TriggerWebhookWorker)
          .to_not have_received(:perform_async).with('account.approved', 'Account', user.account_id)
      end
    end

    context 'when the user is a new user' do
      let(:user) { Fabricate(:user, confirmed_at: nil, unconfirmed_email: new_email) }

      context 'when the user does not require explicit approval' do
        before { Setting.registrations_mode = 'open' }

        it 'sets email to unconfirmed_email and triggers `account.approved` web hook' do
          expect { subject }
            .to change { user.reload.email }.to(new_email)
          expect(TriggerWebhookWorker)
            .to have_received(:perform_async).with('account.approved', 'Account', user.account_id).once
        end
      end

      context 'when the user requires explicit approval because of signup IP address' do
        let(:user) { Fabricate(:user, confirmed_at: nil, unconfirmed_email: new_email, approved: false, sign_up_ip: '192.0.2.5') }

        before do
          Setting.registrations_mode = 'open'
          Fabricate(:ip_block, ip: '192.0.2.5', severity: :sign_up_requires_approval)
        end

        it 'sets email to new_email and marks user as confirmed, but not as approved and does not trigger `account.approved` web hook' do
          expect { subject }
            .to change { user.reload.email }.to(new_email)
            .and change { user.reload.confirmed_at }.from(nil)
            .and not_change { user.reload.approved }.from(false)
          expect(TriggerWebhookWorker)
            .to_not have_received(:perform_async).with('account.approved', 'Account', user.account_id)
        end
      end

      context 'when the user requires explicit approval because of username' do
        let(:user) { Fabricate(:user, confirmed_at: nil, unconfirmed_email: new_email, approved: false, account_attributes: { username: 'VeryStrangeUsername' }) }

        before do
          Setting.registrations_mode = 'open'
          Fabricate(:username_block, username: 'StrangeUser', exact: false, allow_with_approval: true)
        end

        it 'sets email to new_email and marks user as confirmed, but not as approved and does not trigger `account.approved` web hook' do
          expect { subject }
            .to change { user.reload.email }.to(new_email)
            .and change { user.reload.confirmed_at }.from(nil)
            .and not_change { user.reload.approved }.from(false)
          expect(TriggerWebhookWorker)
            .to_not have_received(:perform_async).with('account.approved', 'Account', user.account_id)
        end
      end

      context 'when registrations mode is approved' do
        before { Setting.registrations_mode = 'approved' }

        context 'when the user is already approved' do
          before { user.approve! }

          it 'sets email to unconfirmed_email and triggers `account.approved` web hook' do
            expect { subject }
              .to change { user.reload.email }.to(new_email)
            expect(TriggerWebhookWorker)
              .to have_received(:perform_async).with('account.approved', 'Account', user.account_id).once
          end
        end

        context 'when the user is not approved' do
          it 'sets email to unconfirmed_email and does not trigger web hook' do
            expect { subject }
              .to change { user.reload.email }.to(new_email)
            expect(TriggerWebhookWorker)
              .to_not have_received(:perform_async).with('account.approved', 'Account', user.account_id)
          end
        end
      end
    end
  end
end
