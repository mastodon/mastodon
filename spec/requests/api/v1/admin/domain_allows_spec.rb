# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Domain Allows' do
  include_context 'with API authentication', user_fabricator: :admin_user, oauth_scopes: 'admin:read admin:write'

  describe 'GET /api/v1/admin/domain_allows' do
    subject do
      get '/api/v1/admin/domain_allows', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    context 'when there is no allowed domains' do
      it 'returns an empty body' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to be_empty
      end
    end

    context 'when there are allowed domains' do
      let!(:domain_allows) { Fabricate.times(2, :domain_allow) }
      let(:expected_response) do
        domain_allows.map do |domain_allow|
          {
            id: domain_allow.id.to_s,
            domain: domain_allow.domain,
            created_at: domain_allow.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
          }
        end
      end

      it 'returns the correct allowed domains' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to match_array(expected_response)
      end

      context 'with limit param' do
        let(:params) { { limit: 1 } }

        it 'returns only the requested number of allowed domains' do
          subject

          expect(response.parsed_body.size).to eq(params[:limit])
        end
      end
    end
  end

  describe 'GET /api/v1/admin/domain_allows/:id' do
    subject do
      get "/api/v1/admin/domain_allows/#{domain_allow.id}", headers: headers
    end

    let!(:domain_allow) { Fabricate(:domain_allow) }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns the expected allowed domain name', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body[:domain]).to eq domain_allow.domain
    end

    context 'when the requested allowed domain does not exist' do
      it 'returns http not found' do
        get '/api/v1/admin/domain_allows/-1', headers: headers

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/admin/domain_allows' do
    subject do
      post '/api/v1/admin/domain_allows', headers: headers, params: params
    end

    let(:params) { { domain: 'foo.bar.com' } }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    context 'with a valid domain name' do
      it 'returns the expected domain name', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:domain]).to eq 'foo.bar.com'
        expect(DomainAllow.find_by(domain: 'foo.bar.com')).to be_present
      end
    end

    context 'with invalid domain name' do
      let(:params) { { domain: 'foo bar' } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when domain name is not specified' do
      let(:params) { {} }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the domain is already allowed' do
      before do
        DomainAllow.create(params)
      end

      it 'returns the existing allowed domain name' do
        subject

        expect(response.parsed_body[:domain]).to eq(params[:domain])
      end
    end
  end

  describe 'DELETE /api/v1/admin/domain_allows/:id' do
    subject do
      delete "/api/v1/admin/domain_allows/#{domain_allow.id}", headers: headers
    end

    let!(:domain_allow) { Fabricate(:domain_allow) }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'deletes the allowed domain', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(DomainAllow.find_by(id: domain_allow.id)).to be_nil
    end

    context 'when the allowed domain does not exist' do
      it 'returns http not found' do
        delete '/api/v1/admin/domain_allows/-1', headers: headers

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
