# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Relay do
  describe 'Normalizations' do
    describe 'inbox_url' do
      it { is_expected.to normalize(:inbox_url).from('  http://host.example  ').to('http://host.example') }
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:inbox_url) }
    it { is_expected.to validate_uniqueness_of(:inbox_url) }
  end

  describe 'Enumerations' do
    it { is_expected.to define_enum_for(:state) }
  end

  describe 'Scopes' do
    describe 'enabled' do
      let!(:accepted_relay) { Fabricate :relay, state: :accepted }
      let!(:pending_relay) { Fabricate :relay, state: :pending }

      it 'returns records in accepted state' do
        expect(described_class.enabled)
          .to include(accepted_relay)
          .and not_include(pending_relay)
      end
    end
  end

  describe 'Callbacks' do
    describe 'Ensure disabled on destroy' do
      before { stub_services }

      context 'when relay is enabled' do
        let(:relay) { Fabricate :relay, state: :accepted }

        it 'sends undo when destroying the record' do
          relay.destroy!

          expect(ActivityPub::DeliveryWorker)
            .to have_received(:perform_async).with(match('Undo'), Account.representative.id, relay.inbox_url)
        end
      end

      context 'when relay is not enabled' do
        let(:relay) { Fabricate :relay, state: :pending }

        it 'sends undo when destroying the record' do
          relay.destroy!

          expect(ActivityPub::DeliveryWorker)
            .to_not have_received(:perform_async)
        end
      end
    end
  end

  describe '#to_log_human_identifier' do
    subject { relay.to_log_human_identifier }

    let(:relay) { Fabricate.build :relay, inbox_url: }
    let(:inbox_url) { 'https://host.example' }

    it { is_expected.to eq(inbox_url) }
  end

  describe '#disable' do
    let(:relay) { Fabricate :relay, state: :accepted, follow_activity_id: 'https://host.example/123' }

    before { stub_services }

    it 'changes state to idle and removes the activity id' do
      expect { relay.disable! }
        .to change { relay.reload.state }.to('idle')
        .and change { relay.reload.follow_activity_id }.to(be_nil)
      expect(ActivityPub::DeliveryWorker)
        .to have_received(:perform_async).with(match('Undo'), Account.representative.id, relay.inbox_url)
      expect(DeliveryFailureTracker)
        .to have_received(:reset!).with(relay.inbox_url)
    end
  end

  describe '#enable' do
    let(:relay) { Fabricate :relay, state: :idle, follow_activity_id: '' }

    before { stub_services }

    it 'changes state to pending and populates the activity id' do
      expect { relay.enable! }
        .to change { relay.reload.state }.to('pending')
        .and change { relay.reload.follow_activity_id }.to(be_present)
      expect(ActivityPub::DeliveryWorker)
        .to have_received(:perform_async).with(match('Follow'), Account.representative.id, relay.inbox_url)
      expect(DeliveryFailureTracker)
        .to have_received(:reset!).with(relay.inbox_url)
    end
  end

  def stub_services
    allow(ActivityPub::DeliveryWorker).to receive(:perform_async)
    allow(DeliveryFailureTracker).to receive(:reset!)
  end
end
