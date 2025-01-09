# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AfterAccountDomainBlockWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(AfterBlockDomainFromAccountService, call: true) }

  describe '#perform' do
    before do
      allow(AfterBlockDomainFromAccountService).to receive(:new).and_return(service)
    end

    let(:account) { Fabricate(:account) }
    let(:domain) { 'host.example' }

    it 'sends the account and domain to the service' do
      worker.perform(account.id, domain)

      expect(service).to have_received(:call).with(account, domain)
    end

    it 'returns true for non-existent record' do
      result = worker.perform(123_123_123, domain)

      expect(result).to be(true)
    end
  end
end
