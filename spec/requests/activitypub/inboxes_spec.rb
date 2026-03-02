# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActivityPub Inboxes' do
  let(:remote_account) { nil }

  describe 'POST #create' do
    context 'with signature' do
      let(:remote_account) { Fabricate(:account, domain: 'example.com', protocol: :activitypub) }

      context 'without a named account' do
        subject { post inbox_path, params: {}.to_json, sign_with: remote_account }

        it 'returns http accepted' do
          subject

          expect(response)
            .to have_http_status(202)
        end
      end

      context 'with an excessively large payload' do
        subject { post inbox_path, params: { this: :that, those: :these }.to_json, sign_with: remote_account }

        before { stub_const('ActivityPub::Activity::MAX_JSON_SIZE', 1.byte) }

        it 'returns http content too large' do
          subject

          expect(response)
            .to have_http_status(413)
        end
      end

      context 'with a specific account' do
        subject { post account_inbox_path(account_username: account.username), params: {}.to_json, sign_with: remote_account }

        let(:account) { Fabricate(:account) }

        context 'when account is permanently suspended' do
          before do
            account.suspend!
            account.deletion_request.destroy
          end

          it 'returns http gone' do
            subject

            expect(response)
              .to have_http_status(410)
          end
        end

        context 'when account is temporarily suspended' do
          before { account.suspend! }

          it 'returns http accepted' do
            subject

            expect(response)
              .to have_http_status(202)
          end
        end
      end
    end

    context 'with Collection-Synchronization header' do
      subject { post inbox_path, params: {}.to_json, headers: { 'Collection-Synchronization' => synchronization_header }, sign_with: remote_account }

      let(:remote_account) { Fabricate(:account, followers_url: 'https://example.com/followers', domain: 'example.com', uri: 'https://example.com/actor', protocol: :activitypub) }
      let(:synchronization_collection) { remote_account.followers_url }
      let(:synchronization_url) { 'https://example.com/followers-for-domain' }
      let(:synchronization_hash) { 'somehash' }
      let(:synchronization_header) { "collectionId=\"#{synchronization_collection}\", digest=\"#{synchronization_hash}\", url=\"#{synchronization_url}\"" }

      before do
        stub_follow_sync_worker
        stub_followers_hash
      end

      context 'with mismatching target collection' do
        let(:synchronization_collection) { 'https://example.com/followers2' }

        it 'does not start a synchronization job' do
          subject

          expect(response)
            .to have_http_status(202)
          expect(ActivityPub::FollowersSynchronizationWorker)
            .to_not have_received(:perform_async)
        end
      end

      context 'with mismatching domain in partial collection attribute' do
        let(:synchronization_url) { 'https://example.org/followers' }

        it 'does not start a synchronization job' do
          subject

          expect(response)
            .to have_http_status(202)
          expect(ActivityPub::FollowersSynchronizationWorker)
            .to_not have_received(:perform_async)
        end
      end

      context 'with matching digest' do
        it 'does not start a synchronization job' do
          subject

          expect(response)
            .to have_http_status(202)
          expect(ActivityPub::FollowersSynchronizationWorker)
            .to_not have_received(:perform_async)
        end
      end

      context 'with mismatching digest' do
        let(:synchronization_hash) { 'wronghash' }

        it 'starts a synchronization job' do
          subject

          expect(response)
            .to have_http_status(202)
          expect(ActivityPub::FollowersSynchronizationWorker)
            .to have_received(:perform_async)
        end
      end

      it 'returns http accepted' do
        subject

        expect(response)
          .to have_http_status(202)
      end

      def stub_follow_sync_worker
        allow(ActivityPub::FollowersSynchronizationWorker)
          .to receive(:perform_async)
          .and_return(nil)
      end

      def stub_followers_hash
        Rails.cache.write("followers_hash:#{remote_account.id}:local", 'somehash') # Populate value to match request
      end
    end

    context 'without signature' do
      subject { post inbox_path, params: {}.to_json }

      it 'returns http not authorized' do
        subject

        expect(response)
          .to have_http_status(401)
      end
    end
  end
end
