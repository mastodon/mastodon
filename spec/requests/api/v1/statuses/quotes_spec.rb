# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Statuses Quotes' do
  let(:user) { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  describe 'GET /api/v1/statuses/:status_id/quotes' do
    subject do
      get "/api/v1/statuses/#{status.id}/quotes", headers: headers, params: { limit: 2 }
    end

    let(:scopes) { 'read:statuses' }

    let(:status) { Fabricate(:status, account: user.account) }
    let!(:accepted_quote) { Fabricate(:quote, quoted_status: status, state: :accepted) }
    let!(:rejected_quote) { Fabricate(:quote, quoted_status: status, state: :rejected) }
    let!(:pending_quote) { Fabricate(:quote, quoted_status: status, state: :pending) }
    let!(:accepted_private_quote) { Fabricate(:quote, status: Fabricate(:status, visibility: :private), quoted_status: status, state: :accepted) }

    context 'with an OAuth token' do
      let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

      it_behaves_like 'forbidden for wrong scope', 'write write:statuses'

      it 'returns http success and statuses quoting this post' do
        subject

        expect(response)
          .to have_http_status(200)
          .and include_pagination_headers(
            prev: api_v1_status_quotes_url(limit: 2, since_id: accepted_private_quote.id),
            next: api_v1_status_quotes_url(limit: 2, max_id: accepted_quote.id)
          )
        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to contain_exactly(
            include(id: accepted_quote.status.id.to_s),
            include(id: accepted_private_quote.status.id.to_s)
          )

        expect(response.parsed_body)
          .to_not include(
            include(id: rejected_quote.status.id.to_s),
            include(id: pending_quote.status.id.to_s)
          )
      end

      context 'with a different user than the post owner' do
        let(:status) { Fabricate(:status) }

        it 'returns http success and statuses but not private ones' do
          subject

          expect(response)
            .to have_http_status(200)
            .and include_pagination_headers(
              prev: api_v1_status_quotes_url(limit: 2, since_id: accepted_private_quote.id),
              next: api_v1_status_quotes_url(limit: 2, max_id: accepted_quote.id)
            )
          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to contain_exactly(
              include(id: accepted_quote.status.id.to_s)
            )

          expect(response.parsed_body)
            .to_not include(
              include(id: rejected_quote.status.id.to_s),
              include(id: pending_quote.status.id.to_s),
              include(id: accepted_private_quote.id.to_s)
            )
        end
      end
    end

    context 'without an OAuth token' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/statuses/:status_id/quotes/:id/revoke' do
    subject do
      post "/api/v1/statuses/#{status.id}/quotes/#{quote.status.id}/revoke", headers: headers
    end

    let(:scopes) { 'write:statuses' }

    let(:status) { Fabricate(:status, account: user.account) }
    let!(:quote) { Fabricate(:quote, quoted_status: status, state: :accepted) }

    context 'with an OAuth token' do
      let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

      it_behaves_like 'forbidden for wrong scope', 'read read:statuses'

      context 'with a different user than the post owner' do
        let(:status) { Fabricate(:status) }

        it 'returns http forbidden' do
          subject

          expect(response).to have_http_status(403)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      it 'revokes the quote and returns HTTP success' do
        expect { subject }
          .to change { quote.reload.state }.from('accepted').to('revoked')

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to match(
            a_hash_including(id: quote.status.id.to_s, quote: a_hash_including(state: 'revoked'))
          )
      end
    end

    context 'without an OAuth token' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
