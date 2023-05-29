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

  describe 'about created_at' do
    it 'is truncated by day as UTC' do
      account = Fabricate(:account, created_at: '2023/5/30 12:34:56 +00:00')

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:created_at]).to eq('2023-05-30T00:00:00.000Z')
      end
    end
  end

  describe 'about note' do
    it 'presents note as HTML' do
      Fabricate(:custom_emoji, shortcode: 'foo_emoji')
      account = Fabricate(:account, note: <<~NOTE
        This is note.
        This is second line.
        This line includes :foo_emoji:.
      NOTE
      )

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:note]).to eq('<p>This is note.<br />This is second line.<br />This line includes :foo_emoji:.</p>')
        expect(response_body[:emojis]).to contain_exactly({
          shortcode: 'foo_emoji',
          url: be_an_http_url,
          static_url: be_an_http_url,
          visible_in_picker: true,
        })
      end
    end

    it 'is empty string when account is suspended even if value in note column is present' do
      Fabricate(:custom_emoji, shortcode: 'foo_emoji')
      account = Fabricate(:account, note: 'This line includes :foo_emoji:.', suspended: true)

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:note]).to eq('')
        expect(response_body[:emojis]).to eq([])
      end
    end
  end

  describe 'about url' do
    it 'presents url that build by ActivityPub::TagManager when local account' do
      account = Fabricate(:account, username: 'local_username')

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:url]).to be_an_http_url
        expect(URI.parse(response_body[:url]).path).to eq('/@local_username')
        expect(response_body[:url]).to eq(ActivityPub::TagManager.instance.url_for(account))
      end
    end

    it 'presents value of url column when remote account' do
      account = Fabricate(:account, username: 'remote_username', domain: 'remote.example.com', url: 'https://remote.example.com/users/remote_username')

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:url]).to eq('https://remote.example.com/users/remote_username')
        expect(response_body[:url]).to eq(ActivityPub::TagManager.instance.url_for(account))
      end
    end
  end

  describe 'about image_urls' do
    they 'are HTTP URI' do
      account = Fabricate(:account)

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:avatar]).to be_an_http_url
        expect(response_body[:avatar_static]).to be_an_http_url
        expect(response_body[:header]).to be_an_http_url
        expect(response_body[:header_static]).to be_an_http_url
      end
    end
  end

  describe 'about followers_count' do
    it 'is number of followers' do
      account = Fabricate(:account)
      2.times do
        follower = Fabricate(:account)
        Fabricate(:follow, account: follower, target_account: account)
      end

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:followers_count]).to eq(2)
        expect(response_body[:following_count]).to eq(0)
        expect(response_body[:statuses_count]).to eq(0)
      end
    end
  end
end
