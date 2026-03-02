# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collections' do
  describe 'GET /ap/users/@:account_id/featured_collections', feature: :collections do
    subject { get ap_account_featured_collections_path(account.id, format: :json) }

    let(:collection) { Fabricate(:collection) }
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
        it 'renders ActivityPub Collection successfully', :aggregate_failures do
          subject

          expect(response)
            .to have_http_status(200)
            .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')

          expect(response.headers).to include(
            'Content-Type' => include('application/activity+json')
          )
          expect(response.parsed_body)
            .to include({
              'type' => 'Collection',
              'totalItems' => 1,
              'first' => match(%r{^https://.*page=1.*$}),
            })
        end

        context 'when requesting the first page' do
          subject { get ap_account_featured_collections_path(account.id, page: 1, format: :json) }

          context 'when account has many collections' do
            before do
              Fabricate.times(5, :collection, account:)
            end

            it 'includes a link to the next page', :aggregate_failures do
              subject

              expect(response)
                .to have_http_status(200)

              expect(response.parsed_body)
                .to include({
                  'type' => 'CollectionPage',
                  'totalItems' => 6,
                  'next' => match(%r{^https://.*page=2.*$}),
                })
            end
          end
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
        get ap_account_featured_collections_path(account.id, format: :json),
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
        it 'renders ActivityPub FeaturedCollection object successfully', :aggregate_failures do
          subject

          expect(response)
            .to have_http_status(200)
            .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')

          expect(response.headers).to include(
            'Content-Type' => include('application/activity+json')
          )
          expect(response.parsed_body)
            .to include({
              'type' => 'Collection',
              'totalItems' => 1,
            })
        end
      end
    end
  end
end
