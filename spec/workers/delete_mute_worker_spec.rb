# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteMuteWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(UnmuteService, call: true) }

  describe '#perform' do
    before do
      allow(UnmuteService).to receive(:new).and_return(service)
    end

    context 'with an expired mute' do
      let(:mute) { Fabricate(:mute, expires_at: 1.day.ago) }

      it 'sends the mute to the service' do
        worker.perform(mute.id)

        expect(service).to have_received(:call).with(mute.account, mute.target_account)
      end
    end

    context 'with an unexpired mute' do
      let(:mute) { Fabricate(:mute, expires_at: 1.day.from_now) }

      it 'does not send the mute to the service' do
        worker.perform(mute.id)

        expect(service).to_not have_received(:call)
      end
    end

    context 'with a non-existent mute' do
      it 'does not send the mute to the service' do
        worker.perform(123_123_123)

        expect(service).to_not have_received(:call)
      end
    end
  end
end
