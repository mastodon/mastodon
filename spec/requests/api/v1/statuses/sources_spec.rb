# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sources' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read:statuses' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/statuses/:status_id/source' do
    subject do
      get "/api/v1/statuses/#{status.id}/source", headers: headers
    end

    let(:status) { Fabricate(:status) }

    it_behaves_like 'forbidden for wrong scope', 'write write:statuses'

    context 'with public status' do
      it 'returns the source properties of the status', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to match({
          id: status.id.to_s,
          text: status.text,
          spoiler_text: status.spoiler_text,
        })
      end
    end

    context 'with private status of non-followed account' do
      let(:status) { Fabricate(:status, visibility: :private) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with private status of followed account' do
      let(:status) { Fabricate(:status, visibility: :private) }

      before do
        user.account.follow!(status.account)
      end

      it 'returns the source properties of the status', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to match({
          id: status.id.to_s,
          text: status.text,
          spoiler_text: status.spoiler_text,
        })
      end
    end

    context 'without an authorization header' do
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
