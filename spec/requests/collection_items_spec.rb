# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CollectionItems' do
  describe 'GET /ap/users/@:account_id/collection_items/:id', feature: :collections do
    subject { get ap_account_collection_item_path(account.id, collection_item, format: :json) }

    let(:collection_item) { Fabricate(:collection_item) }
    let(:collection) { collection_item.collection }
    let(:account) { collection.account }

    context 'when signed out' do
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

        it 'returns http forbidden' do
          subject

          expect(response)
            .to have_http_status(403)
        end
      end

      context 'when account is accessible' do
        it 'renders ActivityPub representation successfully', :aggregate_failures do
          subject

          expect(response)
            .to have_http_status(200)
            .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')

          expect(response.headers).to include(
            'Content-Type' => include('application/activity+json')
          )
          expect(response.parsed_body)
            .to include({
              'type' => 'FeaturedItem',
            })
        end
      end
    end

    context 'when signed in' do
      let(:user) { Fabricate(:user) }

      before do
        post user_session_path, params: { user: { email: user.email, password: user.password } }
      end

      context 'when account blocks user' do
        before { account.block!(user.account) }

        it 'returns http not found' do
          subject

          expect(response)
            .to have_http_status(404)
        end
      end
    end

    context 'with "HTTP Signature" access signed by a remote account' do
      subject do
        get ap_account_collection_item_path(account.id, collection_item, format: :json),
            headers: nil,
            sign_with: remote_account
      end

      let(:remote_account) { Fabricate(:account, domain: 'host.example') }

      context 'when account blocks the remote account' do
        before { account.block!(remote_account) }

        it 'returns http not found' do
          subject

          expect(response)
            .to have_http_status(404)
        end
      end

      context 'when account domain blocks the domain of the remote account' do
        before { account.block_domain!(remote_account.domain) }

        it 'returns http not found' do
          subject

          expect(response)
            .to have_http_status(404)
        end
      end

      context 'with JSON' do
        it 'renders ActivityPub FeaturedItem object successfully', :aggregate_failures do
          subject

          expect(response)
            .to have_http_status(200)
            .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')

          expect(response.headers).to include(
            'Content-Type' => include('application/activity+json')
          )
          expect(response.parsed_body)
            .to include({
              'type' => 'FeaturedItem',
            })
        end
      end
    end
  end
end
