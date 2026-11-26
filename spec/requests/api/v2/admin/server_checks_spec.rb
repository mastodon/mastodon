# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V2 Admin ServerChecks' do
  let(:role) do
    Fabricate(:user_role, permissions_as_keys: [:administrator])
  end
  let(:user) { Fabricate(:user, role:) }
  let(:scopes) { 'admin:read' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET #index' do
    before do
      Admin::ServerCheck.destroy_all

      Fabricate('Admin::ServerCheck', key: 'rules', status: :pending, severity: :warning)
      Fabricate('Admin::ServerCheck', key: 'sidekiq_process', status: :pending, severity: :critical)
      Fabricate('Admin::ServerCheck', key: 'software_version', status: :pending, severity: :critical, data: { reason: :urgent })
      Fabricate('Admin::ServerCheck', key: 'database_schema', status: :ok)
      Fabricate('Admin::ServerCheck', key: 'elastic_search', status: :pending, ignored: true)
      Fabricate('Admin::ServerCheck', key: 'media_privacy', status: :unprocessed)

      get '/api/v2/admin/server_checks', headers: headers
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns 200 OK' do
      expect(response).to have_http_status(200)
    end

    it 'returns json response' do
      expect(response.content_type)
        .to start_with('application/json')
    end

    it 'returns a list of checks' do
      expect(response.parsed_body)
        .to contain_exactly(
          include('key' => 'rules'),
          include('key' => 'sidekiq_process'),
          include('key' => 'software_version'),
          include('key' => 'database_schema'),
          include('key' => 'elastic_search'),
          include('key' => 'media_privacy')
        )
    end
  end
end
