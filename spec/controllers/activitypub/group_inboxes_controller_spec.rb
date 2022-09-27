# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::GroupInboxesController, type: :controller do
  let(:remote_account) { nil }
  let(:group) { Fabricate(:group) }
  let(:service_stub) { double(call: nil) }

  before do
    allow(ActivityPub::ProcessCollectionService).to receive(:new).and_return(service_stub)
    allow(controller).to receive(:signed_request_actor).and_return(remote_account)
  end

  describe 'POST #create' do
    let(:json) do
      {
        '@context': 'https://www.w3.org/ns/activitystreams',
        id: 'https://example.com/activities/1',
        type: 'Create',
        actor: 'https://example.com/actor/1',
        object: 'https://example.com/objects/1',
      }.with_indifferent_access
    end

    subject(:response) { post :create, params: { group_id: group.id }, body: Oj.dump(json) }

    context 'with signature' do
      let(:remote_account) { Fabricate(:account, domain: 'example.com', protocol: :activitypub) }

      it 'returns http accepted' do
        expect(response).to have_http_status(202)
      end

      it 'calls ActivityPub::ProcessCollectionService' do
        response
        expect(service_stub).to have_received(:call)
      end

      context 'when group is permanently suspended' do
        before do
          group.suspend!
          group.deletion_request.destroy
        end

        it 'returns http gone' do
          expect(response).to have_http_status(410)
        end
      end

      context 'when group is temporarily suspended' do
        before do
          group.suspend!
        end

        it 'returns http accepted' do
          expect(response).to have_http_status(202)
        end
      end
    end

    context 'without signature' do
      before do
        post :create, params: { group_id: group.id }, body: '{}'
      end

      it 'returns http not authorized' do
        expect(response).to have_http_status(401)
      end
    end
  end
end
