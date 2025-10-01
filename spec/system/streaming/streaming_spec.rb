# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Streaming', :inline_jobs, :streaming do
  let(:authentication_method) { StreamingClient::AUTHENTICATION::SUBPROTOCOL }
  let(:user) { Fabricate(:user) }
  let(:scopes) { '' }
  let(:application) { Fabricate(:application, confidential: false) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, application: application, scopes: scopes) }
  let(:access_token) { token.token }

  before do
    streaming_client.authenticate(access_token, authentication_method)
  end

  after do
    streaming_client.close
  end

  context 'when authenticating via subprotocol' do
    it 'is able to connect' do
      streaming_client.connect

      expect(streaming_client.status).to eq(101)
      expect(streaming_client.open?).to be(true)
    end
  end

  context 'when authenticating via authorization header' do
    let(:authentication_method) { StreamingClient::AUTHENTICATION::AUTHORIZATION_HEADER }

    it 'is able to connect successfully' do
      streaming_client.connect

      expect(streaming_client.status).to eq(101)
      expect(streaming_client.open?).to be(true)
    end
  end

  context 'when authenticating via query parameter' do
    let(:authentication_method) { StreamingClient::AUTHENTICATION::QUERY_PARAMETER }

    it 'is able to connect successfully' do
      streaming_client.connect

      expect(streaming_client.status).to eq(101)
      expect(streaming_client.open?).to be(true)
    end
  end

  context 'with a revoked access token' do
    before do
      token.revoke
    end

    it 'receives an 401 unauthorized error' do
      streaming_client.connect

      expect(streaming_client.status).to eq(401)
      expect(streaming_client.open?).to be(false)
    end
  end

  context 'when revoking an access token after connection' do
    it 'disconnects the client' do
      streaming_client.connect

      expect(streaming_client.status).to eq(101)
      expect(streaming_client.open?).to be(true)

      token.revoke

      expect(streaming_client.wait_for(:closed).code).to be(1000)
      expect(streaming_client.open?).to be(false)
    end
  end
end
