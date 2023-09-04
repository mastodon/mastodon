# frozen_string_literal: true

require 'rails_helper'

describe Admin::DomainPurgeWorker do
  subject { described_class.new }

  describe 'perform' do
    it 'calls domain purge service for relevant domain block' do
      service = double(call: nil)
      allow(PurgeDomainService).to receive(:new).and_return(service)
      result = subject.perform('example.com')

      expect(result).to be_nil
      expect(service).to have_received(:call).with('example.com')
    end
  end
end
