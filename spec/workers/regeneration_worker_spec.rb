# frozen_string_literal: true

require 'rails_helper'

describe RegenerationWorker do
  subject { described_class.new }

  describe 'perform' do
    let(:account) { Fabricate(:account) }

    it 'calls the precompute feed service for the account' do
      service = double(call: nil)
      allow(PrecomputeFeedService).to receive(:new).and_return(service)
      result = subject.perform(account.id)

      expect(result).to be_nil
      expect(service).to have_received(:call).with(account)
    end

    it 'fails when account does not exist' do
      result = subject.perform('aaa')

      expect(result).to eq(true)
    end
  end
end
