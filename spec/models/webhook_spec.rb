# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webhook do
  let(:webhook) { Fabricate(:webhook) }

  describe 'Validations' do
    subject { Fabricate.build :webhook }

    it { is_expected.to validate_presence_of(:events) }

    it { is_expected.to_not allow_values([], %w(account.invalid)).for(:events) }
  end

  describe 'Normalizations' do
    describe 'events' do
      it { is_expected.to normalize(:events).from(['account.approved', 'account.created     ', '']).to(%w(account.approved account.created)) }
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
