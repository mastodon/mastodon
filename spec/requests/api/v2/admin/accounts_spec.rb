# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V2 Admin Accounts' do
  let(:role)   { UserRole.find_by(name: 'Moderator') }
  let(:user)   { Fabricate(:user, role: role) }
  let(:scopes) { 'admin:read admin:write' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET #index' do
    let!(:remote_account)       { Fabricate(:account, domain: 'example.org') }
    let!(:other_remote_account) { Fabricate(:account, domain: 'foo.bar') }
    let!(:suspended_account)    { Fabricate(:account, suspended: true) }
    let!(:suspended_remote)     { Fabricate(:account, domain: 'foo.bar', suspended: true) }
    let!(:disabled_account)     { Fabricate(:user, disabled: true).account }
    let!(:pending_account)      { Fabricate(:user, approved: false).account }
    let!(:admin_account)        { user.account }

    let(:params) { {} }

    before do
      pending_account.user.update(approved: false)

      get '/api/v2/admin/accounts', params: params, headers: headers
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    context 'when called with status active and origin local and permissions staff' do
      let(:params) { { status: 'active', origin: 'local', permissions: 'staff' } }

      it 'returns the correct accounts' do
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to contain_exactly(
            hash_including(id: admin_account.id.to_s)
          )
      end
    end

    context 'when called with by_domain value and origin remote' do
      let(:params) { { by_domain: 'example.org', origin: 'remote' } }

      it 'returns the correct accounts' do
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to contain_exactly(
            hash_including(id: remote_account.id.to_s)
          )
          .and not_include(hash_including(id: other_remote_account.id.to_s))
      end
    end

    context 'when called with status suspended' do
      let(:params) { { status: 'suspended' } }

      it 'returns the correct accounts' do
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to contain_exactly(
            hash_including(id: suspended_remote.id.to_s),
            hash_including(id: suspended_account.id.to_s)
          )
      end
    end

    context 'when called with status disabled' do
      let(:params) { { status: 'disabled' } }

      it 'returns the correct accounts' do
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to contain_exactly(
            hash_including(id: disabled_account.id.to_s)
          )
      end
    end

    context 'when called with status pending' do
      let(:params) { { status: 'pending' } }

      it 'returns the correct accounts' do
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to contain_exactly(
            hash_including(id: pending_account.id.to_s)
          )
      end
    end

    context 'with limit param' do
      let(:params) { { limit: 1 } }

      it 'sets the correct pagination headers' do
        expect(response)
          .to include_pagination_headers(next: api_v2_admin_accounts_url(limit: 1, max_id: admin_account.id))
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
