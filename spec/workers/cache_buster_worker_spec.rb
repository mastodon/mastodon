# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CacheBusterWorker do
  let(:worker) { described_class.new }

  describe 'perform' do
    let(:path) { 'https://example.com' }
    let(:service) { instance_double(CacheBuster, bust: true) }

    it 'calls the cache buster' do
      allow(CacheBuster).to receive(:new).and_return(service)
      worker.perform(path)

      expect(service).to have_received(:bust).with(path)
    end
  end
end
