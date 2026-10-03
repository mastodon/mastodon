# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::RelayPreferencesBatch do
  let(:batch) { described_class.new }

  describe '#save' do
    subject { batch.save }

    let!(:relay) { Fabricate(:relay, requires_opt_in: true) }
    let(:relay_ids) { [] }
    let(:current_account) { Fabricate(:account) }

    before do
      batch.assign_attributes(
        current_account:,
        relay_ids:
      )
    end

    context 'when user has not been opted-in before' do
      let(:relay_ids) { [relay.id] }

      it 'creates a relay preference' do
        expect { subject }.to change { RelayPreference.where(account: current_account, relay:, enabled: true).count }.from(0).to(1)
      end
    end

    context 'when user has been opted-in before' do
      let(:relay_ids) { [] }
      let!(:relay_preference) { RelayPreference.create!(account: current_account, relay:, enabled: true) }

      it 'updates relay preference' do
        expect { subject }.to change { relay_preference.reload.enabled? }.from(true).to(false)
          .and change { current_account.blocking?(relay.account) }.from(false).to(true)
      end

      it 'sends block activity to relay' do
        allow(ActivityPub::DeliveryWorker).to receive(:perform_async)
        subject
        expect(ActivityPub::DeliveryWorker).to have_received(:perform_async).with(match('Block'), current_account.id, relay.inbox_url)
      end
    end

    context 'when user has opted-out before' do
      let(:relay_ids) { [relay.id] }
      let(:relay_preference) { RelayPreference.create!(account: current_account, relay:, enabled: false) }

      before do
        relay_preference.account.block!(relay.account)
      end

      it 'updates relay preference' do
        expect { subject }.to change { relay_preference.reload.enabled? }.from(false).to(true)
          .and change { current_account.blocking?(relay.account) }.from(true).to(false)
      end

      it 'sends undo block activity to relay' do
        allow(ActivityPub::DeliveryWorker).to receive(:perform_async)
        subject
        expect(ActivityPub::DeliveryWorker).to have_received(:perform_async).with(match('Undo'), current_account.id, relay.inbox_url)
      end
    end
  end
end
