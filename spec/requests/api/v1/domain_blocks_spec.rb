# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Domain blocks' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:blocks write:blocks' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/domain_blocks' do
    subject do
      get '/api/v1/domain_blocks', headers: headers, params: params
    end

    let(:blocked_domains) { ['example.com', 'example.net', 'example.org', 'example.com.br'] }
    let(:params) { {} }

    before do
      blocked_domains.each { |domain| user.account.block_domain!(domain) }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:blocks'

    it 'returns the domains blocked by the requesting user', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to match_array(blocked_domains)
    end

    context 'with limit param' do
      let(:params) { { limit: 2 } }

      it 'returns only the requested number of blocked domains' do
        subject

        expect(response.parsed_body.size).to eq(params[:limit])
      end
    end
  end

  describe 'POST /api/v1/domain_blocks' do
    subject do
      post '/api/v1/domain_blocks', headers: headers, params: params
    end

    let(:params) { { domain: 'example.com' } }

    it_behaves_like 'forbidden for wrong scope', 'read read:blocks'

    it 'creates a domain block', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(user.account.domain_blocking?(params[:domain])).to be(true)
    end

    context 'when no domain name is given' do
      let(:params) { { domain: '' } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'when the given domain name is invalid' do
      let(:params) { { domain: 'example com' } }

      it 'returns unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /api/v1/domain_blocks' do
    subject do
      delete '/api/v1/domain_blocks/', headers: headers, params: params
    end

    let(:params) { { domain: 'example.com' } }

    before do
      user.account.block_domain!('example.com')
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:blocks'

    it 'deletes the specified domain block', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(user.account.domain_blocking?('example.com')).to be(false)
    end

    context 'when the given domain name is not blocked' do
      let(:params) { { domain: 'example.org' } }

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end
    end
  end
end
