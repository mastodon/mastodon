# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webhook do
  let(:webhook) { Fabricate(:webhook) }

  describe 'Validations' do
    subject { Fabricate.build :webhook }

    it { is_expected.to validate_length_of(:secret).is_at_least(described_class::SECRET_LENGTH_MIN) }

    it { is_expected.to validate_presence_of(:events) }

    it { is_expected.to_not allow_values([], %w(account.invalid)).for(:events) }

    it { is_expected.to_not allow_values('{{account }').for(:template) }

    context 'when current_account is assigned' do
      subject { Fabricate.build :webhook, current_account: account }

      context 'with account that has permissions' do
        let(:account) { Fabricate(:admin_user).account }

        it { is_expected.to allow_values(%w(account.created)).for(:events) }
      end

      context 'with account lacking permissions' do
        let(:account) { Fabricate :account }

        it { is_expected.to_not allow_values(%w(account.created)).for(:events) }
      end
    end
  end

  describe 'Normalizations' do
    describe 'events' do
      it { is_expected.to normalize(:events).from(['account.approved', 'account.created     ', '']).to(%w(account.approved account.created)) }
    end
  end

  describe 'Callbacks' do
    describe 'Generating a secret' do
      context 'when secret exists already' do
        subject { described_class.new(secret: 'secret') }

        it 'does not override' do
          expect { subject.valid? }
            .to_not change(subject, :secret)
        end
      end

      context 'when secret does not exist' do
        subject { described_class.new(secret: nil) }

        it 'does not override' do
          expect { subject.valid? }
            .to change(subject, :secret)
        end
      end
    end
  end

  describe '.permission_for_event' do
    subject { described_class.permission_for_event(event) }

    context 'with a nil value' do
      let(:event) { nil }

      it { is_expected.to be_nil }
    end

    context 'with an account approved event' do
      let(:event) { 'account.approved' }

      it { is_expected.to eq(:manage_users) }
    end

    context 'with an account created event' do
      let(:event) { 'account.created' }

      it { is_expected.to eq(:manage_users) }
    end

    context 'with an account updated event' do
      let(:event) { 'account.updated' }

      it { is_expected.to eq(:manage_users) }
    end

    context 'with an report created event' do
      let(:event) { 'report.created' }

      it { is_expected.to eq(:manage_reports) }
    end

    context 'with an report updated event' do
      let(:event) { 'report.updated' }

      it { is_expected.to eq(:manage_reports) }
    end

    context 'with an status created event' do
      let(:event) { 'status.created' }

      it { is_expected.to eq(:view_devops) }
    end

    context 'with an status updated event' do
      let(:event) { 'status.updated' }

      it { is_expected.to eq(:view_devops) }
    end
  end

  describe '#required_permissions' do
    subject { described_class.new(events:).required_permissions }

    context 'with empty events' do
      let(:events) { [] }

      it { is_expected.to eq([]) }
    end

    context 'with multiple event types' do
      let(:events) { %w(account.created account.updated status.created) }

      it { is_expected.to eq %i(manage_users view_devops) }
    end
  end

  describe '#rotate_secret!' do
    it 'changes the secret' do
      expect { webhook.rotate_secret! }
        .to change(webhook, :secret)
      expect(webhook.secret)
        .to_not be_blank
    end
  end

  describe '#enable!' do
    let(:webhook) { Fabricate(:webhook, enabled: false) }

    it 'enables the webhook' do
      expect { webhook.enable! }
        .to change(webhook, :enabled?).to(true)
    end
  end

  describe '#disable!' do
    let(:webhook) { Fabricate(:webhook, enabled: true) }

    it 'disables the webhook' do
      expect { webhook.disable! }
        .to change(webhook, :enabled?).to(false)
    end
  end
end
