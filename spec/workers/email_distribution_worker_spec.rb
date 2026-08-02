# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailDistributionWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    subject { worker.perform(account_id) }

    let(:account_id) { nil }

    context 'when email subscription setting is true but configuration is false' do
      around do |example|
        original = Rails.application.config.x.email_subscriptions
        Rails.application.config.x.email_subscriptions = false
        Setting.email_subscriptions = true
        example.run
        Rails.application.config.x.email_subscriptions = original
      end

      it { is_expected.to be_nil }
    end

    context 'when email subscription setting is false and configuration is true' do
      around do |example|
        original = Rails.application.config.x.email_subscriptions
        Rails.application.config.x.email_subscriptions = true
        Setting.email_subscriptions = false
        example.run
        Rails.application.config.x.email_subscriptions = original
      end

      it { is_expected.to be_nil }
    end

    context 'when email subscription setting and configuration are enabled' do
      around do |example|
        original = Rails.application.config.x.email_subscriptions
        Rails.application.config.x.email_subscriptions = true
        Setting.email_subscriptions = true
        example.run
        Rails.application.config.x.email_subscriptions = original
      end

      context 'when account is invalid' do
        let(:account_id) { 123_123_123 }

        it { is_expected.to be_nil }
      end

      context 'when user has subscriptions disabled' do
        let(:account_id) { account.id }
        let(:account) { Fabricate.build :account, user: }
        let(:user) { Fabricate.build :user }

        before { user.settings['email_subscriptions'] = false }

        it { is_expected.to be_nil }
      end

      context 'when user has subscriptions enabled' do
        let(:account_id) { account.id }
        let(:account) { Fabricate :account, user: }
        let(:user) { Fabricate :user, role: }
        let(:role) { Fabricate(:user_role, permissions: UserRole::FLAGS[:manage_email_subscriptions]) }

        before { user.settings['email_subscriptions'] = true }

        context 'when user does not have subscriptions' do
          it { is_expected.to be_nil }
        end

        context 'when user has subscriptions' do
          let!(:email_subscription) { Fabricate :email_subscription, confirmed_at: 2.days.ago, account: }

          context 'when user does not have statuses' do
            it { is_expected.to be_nil }
          end

          context 'when user has statuses', :inline_jobs do
            let(:status) { Fabricate :status, account: }

            before do
              # Simulate PostStatusService marking for delivery
              redis.sadd("email_subscriptions:#{account_id}:next_batch", status.id)
            end

            it 'sends email to subscribed address' do
              expect { subject }
                .to send_email(to: email_subscription.email)
            end
          end
        end
      end
    end
  end
end
