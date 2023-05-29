# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/v1/accounts/{account_id}' do
  it 'returns account entity as 200 OK' do
    account = Fabricate(:account)

    get "/api/v1/accounts/#{account.id}"

    aggregate_failures do
      expect(response).to have_http_status(200)
      expect(body_as_json[:id]).to eq(account.id.to_s)
    end
  end

  it 'returns 404 if account not found' do
    get '/api/v1/accounts/1'

    aggregate_failures do
      expect(response).to have_http_status(404)
      expect(body_as_json[:error]).to eq('Record not found')
    end
  end

  context 'when with token' do
    it 'returns account entity as 200 OK if token is valid' do
      account = Fabricate(:account)
      user = Fabricate(:user, account: account)
      token = Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:accounts').token

      get "/api/v1/accounts/#{account.id}", headers: { Authorization: "Bearer #{token}" }

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(body_as_json[:id]).to eq(account.id.to_s)
      end
    end

    it 'returns 403 if scope of token is invalid' do
      account = Fabricate(:account)
      user = Fabricate(:user, account: account)
      token = Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'write:statuses').token

      get "/api/v1/accounts/#{account.id}", headers: { Authorization: "Bearer #{token}" }

      aggregate_failures do
        expect(response).to have_http_status(403)
        expect(body_as_json[:error]).to eq('This action is outside the authorized scopes')
      end
    end
  end

  describe 'about username' do
    it 'is equal to value in username column' do
      account = Fabricate(:account, username: 'local_username')

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:username]).to eq('local_username')
      end
    end
  end

  describe 'about acct' do
    it 'is equal to username when account is local' do
      account = Fabricate(:account, username: 'local_username')

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:acct]).to eq('local_username')
      end
    end

    it 'includes domain of remote instance when account is remote' do
      account = Fabricate(:account, username: 'remote_username', domain: 'remote.example.com')

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:acct]).to eq('remote_username@remote.example.com')
      end
    end
  end

  describe 'about display_name' do
    it 'is equal to value in display_name column' do
      account = Fabricate(:account, display_name: 'this is display_name')

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:display_name]).to eq('this is display_name')
      end
    end

    it 'is empty if account is suspended' do
      account = Fabricate(:account, display_name: 'this is display_name', suspended: true)

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:display_name]).to eq('')
      end
    end
  end

  describe 'about locked' do
    it 'is false in default' do
      account = Fabricate(:account)

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:locked]).to be(false)
      end
    end

    it 'is true when account is locked' do
      account = Fabricate(:account, locked: true)

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:locked]).to be(true)
      end
    end

    it 'is false when account is suspended even if value in locked column is true' do
      account = Fabricate(:account, locked: true, suspended: true)

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:locked]).to be(false)
      end
    end
  end

  describe 'about bot' do
    it 'is false in default' do
      account = Fabricate(:account)

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:bot]).to be(false)
      end
    end

    it 'is true when account setted as bot' do
      account = Fabricate(:account, bot: true)

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:bot]).to be(true)
      end
    end

    it 'is false when account is suspended even if value in bot column is true' do
      account = Fabricate(:account, bot: true, suspended: true)

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:bot]).to be(false)
      end
    end
  end
end
