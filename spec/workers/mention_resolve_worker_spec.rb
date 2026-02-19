# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MentionResolveWorker do
  let(:status_id) { -42 }
  let(:uri) { 'https://example.com/users/unknown' }

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

      let(:service_double) { instance_double(ActivityPub::FetchRemoteAccountService) }

      before do
        allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(service_double)

        allow(service_double).to receive(:call).with(uri, anything) { Fabricate(:account, domain: 'example.com', uri: uri) }
      end

      it 'resolves the account and adds a new mention', :aggregate_failures do
        expect { subject }
          .to change { status.reload.mentions }.from([]).to(a_collection_including(having_attributes(account: having_attributes(uri: uri), silent: false)))

        expect(service_double).to have_received(:call).once
      end
    end
  end
end
