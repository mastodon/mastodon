# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::VerifyFeaturedItemService do
  subject { described_class.new }

  let(:collection) { Fabricate(:remote_collection) }
  let(:collection_item) do
    Fabricate(:collection_item,
              collection:,
              account: nil,
              state: :pending,
              uri: 'https://other.example.com/items/1',
              object_uri: 'https://example.com/actor/1')
  end
  let(:approval_uri) { 'https://example.com/auth/1' }
  let(:verification_json) do
    {
      '@context' => 'https://www.w3.org/ns/activitystreams',
      'type' => 'FeatureAuthorization',
      'id' => approval_uri,
      'interactionTarget' => 'https://example.com/actor/1',
      'interactingObject' => collection.uri,
    }
  end
  let(:verification_request) do
    stub_request(:get, 'https://example.com/auth/1')
      .to_return_json(
        status: 200,
        body: verification_json,
        headers: { 'Content-Type' => 'application/activity+json' }
      )
  end
  let(:featured_account) { Fabricate(:remote_account, uri: 'https://example.com/actor/1') }

  before { verification_request }

  context 'when the authorization can be verified' do
    context 'when the featured account is known' do
      before { featured_account }

      it 'verifies and creates the item' do
        subject.call(collection_item, approval_uri)

        expect(verification_request).to have_been_requested

        expect(collection_item.account_id).to eq featured_account.id
        expect(collection_item).to be_accepted
        expect(collection_item.approval_uri).to eq approval_uri
      end
    end

    context 'when the featured account is not known' do
      let(:stubbed_service) { instance_double(ActivityPub::FetchRemoteAccountService) }

      before do
        allow(stubbed_service).to receive(:call).with('https://example.com/actor/1', request_id: nil) { featured_account }
        allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(stubbed_service)
      end

      it 'fetches the actor and creates the item' do
        subject.call(collection_item, approval_uri)

        expect(stubbed_service).to have_received(:call)
        expect(verification_request).to have_been_requested

        expect(collection_item.account_id).to eq featured_account.id
        expect(collection_item).to be_accepted
        expect(collection_item.approval_uri).to eq approval_uri
      end
    end
  end

  context 'when the authorization cannot be verified' do
    let(:verification_request) do
      stub_request(:get, 'https://example.com/auth/1')
        .to_return(status: 404)
    end

    it 'creates item without attached account and in proper state' do
      subject.call(collection_item, approval_uri)

      expect(collection_item.account_id).to be_nil
      expect(collection_item).to be_rejected
    end
  end
end
