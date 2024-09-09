# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tags' do
  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:scopes)  { 'admin:read admin:write' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:tag)     { Fabricate(:tag) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/admin/tags' do
    subject do
      get '/api/v1/admin/tags', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    context 'when there are no tags' do
      it 'returns an empty list' do
        subject

        expect(response.parsed_body).to be_empty
      end
    end

    context 'when there are tagss' do
      let!(:tags) do
        [
          Fabricate(:tag),
          Fabricate(:tag),
          Fabricate(:tag),
          Fabricate(:tag),
        ]
      end

      it 'returns the expected tags' do
        subject
        tags.each do |tag|
          expect(response.parsed_body.find { |item| item[:id] == tag.id.to_s && item[:name] == tag.name }).to_not be_nil
        end
      end

      context 'with limit param' do
        let(:params) { { limit: 2 } }

        it 'returns only the requested number of tags' do
          subject

          expect(response.parsed_body.size).to eq(params[:limit])
        end
      end
    end
  end

  describe 'GET /api/v1/admin/tags/:id' do
    subject do
      get "/api/v1/admin/tags/#{tag.id}", headers: headers
    end

    let!(:tag) { Fabricate(:tag) }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns expected tag content' do
      subject

      expect(response.parsed_body[:id].to_i).to eq(tag.id)
      expect(response.parsed_body[:name]).to eq(tag.name)
    end

    context 'when the requested tag does not exist' do
      it 'returns http not found' do
        get '/api/v1/admin/tags/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'PUT /api/v1/admin/tags/:id' do
    subject do
      put "/api/v1/admin/tags/#{tag.id}", headers: headers, params: params
    end

    let!(:tag)   { Fabricate(:tag) }
    let(:params) { { display_name: tag.name.upcase } }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong scope', 'admin:read'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns updated tag' do
      subject

      expect(response.parsed_body[:id].to_i).to eq(tag.id)
      expect(response.parsed_body[:name]).to eq(tag.name.upcase)
    end

    context 'when the updated display name is invalid' do
      let(:params) { { display_name: tag.name + tag.id.to_s } }

      it 'returns http unprocessable content' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'when the requested tag does not exist' do
      it 'returns http not found' do
        get '/api/v1/admin/tags/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end
end
