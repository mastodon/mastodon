# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SuspensionWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(SuspendAccountService, call: true) }

  describe '#perform' do
    before do
      allow(SuspendAccountService).to receive(:new).and_return(service)
    end

    let(:account) { Fabricate(:account) }

    it 'sends the account to the service' do
      worker.perform(account.id)

      expect(service).to have_received(:call).with(account)
    end

    it 'returns true for non-existent record' do
      result = worker.perform(123_123_123)

      expect(result).to be(true)
    end
  end
end
