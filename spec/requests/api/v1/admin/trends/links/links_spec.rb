# frozen_string_literal: true

require 'rails_helper'

describe 'Links' do
  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:scopes)  { 'admin:read admin:write' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/admin/trends/links' do
    subject do
      get '/api/v1/admin/trends/links', headers: headers
    end

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /api/v1/admin/trends/links/:id/approve' do
    subject do
      post "/api/v1/admin/trends/links/#{preview_card.id}/approve", headers: headers
    end

    let(:preview_card) { Fabricate(:preview_card, trendable: false) }

    it_behaves_like 'forbidden for wrong scope', 'read write'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'sets the link as trendable' do
      expect { subject }.to change { preview_card.reload.trendable }.from(false).to(true)
    end

    it 'returns the link data' do
      subject

      expect(body_as_json).to match(
        a_hash_including(
          url: preview_card.url,
          title: preview_card.title,
          description: preview_card.description,
          type: 'link',
          requires_review: false
        )
      )
    end

    context 'when the link does not exist' do
      it 'returns http not found' do
        post '/api/v1/admin/trends/links/-1/approve', headers: headers

        expect(response).to have_http_status(404)
      end
    end

    context 'without an authorization header' do
      let(:headers) { {} }

      it 'returns http forbidden' do
        subject

        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'POST /api/v1/admin/trends/links/:id/reject' do
    subject do
      post "/api/v1/admin/trends/links/#{preview_card.id}/reject", headers: headers
    end

    let(:preview_card) { Fabricate(:preview_card, trendable: false) }

    it_behaves_like 'forbidden for wrong scope', 'read write'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'does not set the link as trendable' do
      expect { subject }.to_not(change { preview_card.reload.trendable })
    end

    it 'returns the link data' do
      subject

      expect(body_as_json).to match(
        a_hash_including(
          url: preview_card.url,
          title: preview_card.title,
          description: preview_card.description,
          type: 'link',
          requires_review: false
        )
      )
    end

    context 'when the link does not exist' do
      it 'returns http not found' do
        post '/api/v1/admin/trends/links/-1/reject', headers: headers

        expect(response).to have_http_status(404)
      end
    end

    context 'without an authorization header' do
      let(:headers) { {} }

      it 'returns http forbidden' do
        subject

        expect(response).to have_http_status(403)
      end
    end
  end
end
