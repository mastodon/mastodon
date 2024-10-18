# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveFeaturedTagWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(RemoveFeaturedTagService, call: true) }

  describe 'perform' do
    context 'with missing values' do
      it 'runs without error' do
        expect { worker.perform(nil, nil) }
          .to_not raise_error
      end
    end

    context 'with real records' do
      before { stub_service }

      let(:account) { Fabricate :account }
      let(:featured_tag) { Fabricate :featured_tag }

      it 'calls the service for processing' do
        worker.perform(account.id, featured_tag.id)

        expect(service)
          .to have_received(:call)
          .with(be_an(Account), be_an(FeaturedTag))
      end

      def stub_service
        allow(RemoveFeaturedTagService)
          .to receive(:new)
          .and_return(service)
      end
    end
  end
end
