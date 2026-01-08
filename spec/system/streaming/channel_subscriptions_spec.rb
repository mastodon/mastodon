# frozen_string_literal: true

require 'rails_helper'
require 'debug'

RSpec.describe 'Channel Subscriptions', :inline_jobs, :streaming do
  let(:application) { Fabricate(:application, confidential: false) }
  let(:scopes) { nil }
  let(:access_token) { Fabricate(:accessible_access_token, resource_owner_id: user_account.user.id, application: application, scopes: scopes) }

  let(:user_account) { Fabricate(:account, username: 'alice', domain: nil) }
  let(:bob_account) { Fabricate(:account, username: 'bob') }

  after do
    streaming_client.close
  end

  context 'when the access token has read scope' do
    let(:scopes) { 'read' }

    it 'can subscribing to the public:local channel' do
      streaming_client.authenticate(access_token.token)

      streaming_client.connect
      streaming_client.subscribe('public:local')

      # We need to publish a status as there is no positive acknowledgement of
      # subscriptions:
      status = PostStatusService.new.call(bob_account, text: 'Hello @alice')

      # And then we want to receive that status:
      message = streaming_client.wait_for_message

      expect(message).to include(
        stream: be_an(Array).and(contain_exactly('public:local')),
        event: 'update',
        payload: include(
          id: status.id.to_s
        )
      )
    end
  end

  context 'when the access token cannot read notifications' do
    let(:scopes) { 'read:statuses' }

    it 'cannot subscribing to the user:notifications channel' do
      streaming_client.authenticate(access_token.token)

      streaming_client.connect
      streaming_client.subscribe('user:notification')

      # We should receive an error back immediately:
      message = streaming_client.wait_for_message

      expect(message).to include(
        error: 'Access token does not have the required scopes',
        status: 401
      )
    end
  end
end
