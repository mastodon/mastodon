# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResolveAccountWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(ResolveAccountService, call: true) }

  describe 'perform' do
    context 'with missing values' do
      it 'runs without error' do
        expect { worker.perform(nil) }
          .to_not raise_error
      end
    end

    context 'with a URI' do
      before { stub_service }

      let(:uri) { 'https://host/path/value' }

      it 'initiates account resolution' do
        worker.perform(uri)

        expect(service)
          .to have_received(:call)
          .with(uri)
      end

      def stub_service
        allow(ResolveAccountService)
          .to receive(:new)
          .and_return(service)
      end
    end
  end
end
