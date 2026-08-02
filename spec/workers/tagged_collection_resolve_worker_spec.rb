# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaggedCollectionResolveWorker do
  let(:status_id) { -42 }
  let(:uri) { 'https://example.com/collections/unknown' }

  describe '#perform' do
    subject { described_class.new.perform(status_id, uri, {}) }

    context 'with a non-existent status' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'with a valid user' do
      let(:status) { Fabricate(:status) }
      let(:status_id) { status.id }

      let(:service_double) { instance_double(ActivityPub::FetchRemoteFeaturedCollectionService) }

      before do
        allow(ActivityPub::FetchRemoteFeaturedCollectionService).to receive(:new).and_return(service_double)

        allow(service_double)
          .to receive(:call)
          .with(uri, anything) do
            Fabricate(:remote_collection, account: Fabricate.build(:account, domain: 'example.com'), uri: uri)
          end
      end

      it 'resolves the collection and adds a new tagged object', :aggregate_failures do
        expect { subject }
          .to change { status.reload.tagged_objects }
          .from([])
          .to(a_collection_including(having_attributes(object: having_attributes(uri: uri))))

        expect(service_double).to have_received(:call).once
      end
    end
  end
end
