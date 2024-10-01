# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DomainClearMediaWorker do
  subject { described_class.new }

  describe 'perform' do
    let(:domain_block) { Fabricate(:domain_block, severity: :silence, reject_media: true) }

    it 'calls domain clear media service for relevant domain block' do
      service = instance_double(ClearDomainMediaService, call: nil)
      allow(ClearDomainMediaService).to receive(:new).and_return(service)
      result = subject.perform(domain_block.id)

      expect(result).to be_nil
      expect(service).to have_received(:call).with(domain_block)
    end

    it 'returns true for non-existent domain block' do
      result = subject.perform('aaa')

      expect(result).to be(true)
    end
  end
end
