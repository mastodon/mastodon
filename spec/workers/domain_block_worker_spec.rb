# frozen_string_literal: true

require 'rails_helper'

describe DomainBlockWorker do
  subject { described_class.new }

  describe 'perform' do
    let(:domain_block) { Fabricate(:domain_block) }

    it 'returns true for non-existent domain block' do
      service = double(call: nil)
      allow(BlockDomainService).to receive(:new).and_return(service)
      result = subject.perform(domain_block.id)

      expect(result).to be_nil
      expect(service).to have_received(:call).with(domain_block, false)
    end

    it 'calls domain block service for relevant domain block' do
      result = subject.perform('aaa')

      expect(result).to eq(true)
    end
  end
end
