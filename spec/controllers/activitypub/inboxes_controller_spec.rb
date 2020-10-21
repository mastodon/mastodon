# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::InboxesController, type: :controller do
  let(:remote_account) { nil }

  before do
    allow(controller).to receive(:signed_request_account).and_return(remote_account)
  end

  describe 'POST #create' do
    context 'with signature' do
      let(:remote_account) { Fabricate(:account, domain: 'example.com', protocol: :activitypub) }

      before do
        post :create, body: '{}'
      end

      it 'returns http accepted' do
        expect(response).to have_http_status(202)
      end
    end

    context 'with Collection-Synchronization header' do
      let(:remote_account)             { Fabricate(:account, followers_url: 'https://example.com/followers', domain: 'example.com', uri: 'https://example.com/actor', protocol: :activitypub) }
      let(:synchronization_collection) { remote_account.followers_url }
      let(:synchronization_url)        { 'https://example.com/followers-for-domain' }
      let(:synchronization_hash)       { 'somehash' }
      let(:synchronization_header)     { "collectionId=\"#{synchronization_collection}\", digest=\"#{synchronization_hash}\", url=\"#{synchronization_url}\"" }

      before do
        allow(ActivityPub::FollowersSynchronizationWorker).to receive(:perform_async).and_return(nil)
        allow_any_instance_of(Account).to receive(:local_followers_hash).and_return('somehash')

        request.headers['Collection-Synchronization'] = synchronization_header
        post :create, body: '{}'
      end

      context 'with mismatching target collection' do
        let(:synchronization_collection) { 'https://example.com/followers2' }

        it 'does not start a synchronization job' do
          expect(ActivityPub::FollowersSynchronizationWorker).not_to have_received(:perform_async)
        end
      end

      context 'with mismatching domain in partial collection attribute' do
        let(:synchronization_url) { 'https://example.org/followers' }

        it 'does not start a synchronization job' do
          expect(ActivityPub::FollowersSynchronizationWorker).not_to have_received(:perform_async)
        end
      end

      context 'with matching digest' do
        it 'does not start a synchronization job' do
          expect(ActivityPub::FollowersSynchronizationWorker).not_to have_received(:perform_async)
        end
      end

      context 'with mismatching digest' do
        let(:synchronization_hash) { 'wronghash' }

        it 'starts a synchronization job' do
          expect(ActivityPub::FollowersSynchronizationWorker).to have_received(:perform_async)
        end
      end

      it 'returns http accepted' do
        expect(response).to have_http_status(202)
      end
    end

    context 'without signature' do
      before do
        post :create, body: '{}'
      end

      it 'returns http not authorized' do
        expect(response).to have_http_status(401)
      end
    end
  end
end
