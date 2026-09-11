# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Channel Subscriptions', :inline_jobs, :streaming do
  let(:application) { Fabricate(:application, confidential: false) }
  let(:scopes) { nil }
  let(:access_token) { Fabricate(:accessible_access_token, resource_owner_id: user_account.user.id, application: application, scopes: scopes) }

  let(:user_account) { Fabricate(:account, username: 'alice', domain: nil) }
  let(:bob_account) { Fabricate(:account, username: 'bob') }

  after do
    streaming_client.close
  end

  context 'when the access token has insufficient scope to read statuses' do
    let(:scopes) { 'profile' }

    it 'cannot subscribe to the public:local channel' do
      streaming_client.authenticate(access_token.token)

      streaming_client.connect
      streaming_client.subscribe('public:local')

      # Receive the error back from the subscription attempt:
      message = streaming_client.wait_for_message

      expect(message).to include(
        error: 'Access token does not have the required scopes',
        status: 401
      )
    end
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

    it 'can subscribing to the user:notifications channel' do
      streaming_client.authenticate(access_token.token)

      streaming_client.connect
      streaming_client.subscribe('user:notification')

      # We need to perform an action that triggers a notification as there is
      # no positive acknowledgement of subscriptions:
      first_status = PostStatusService.new.call(user_account, text: 'Test')
      ReblogService.new.call(bob_account, first_status)

      message = streaming_client.wait_for_message

      expect(message).to include(
        event: 'notification',
        stream: ['user:notification']
      )
    end
  end

  context 'when the access token has read:statuses scope' do
    let(:scopes) { 'read:statuses' }

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

  context 'when the access token has read:notifications scope' do
    let(:scopes) { 'read:notifications' }

    it 'can subscribing to the user:notifications channel' do
      streaming_client.authenticate(access_token.token)

      streaming_client.connect
      streaming_client.subscribe('user:notification')

      # We need to perform an action that triggers a notification as there is
      # no positive acknowledgement of subscriptions:
      first_status = PostStatusService.new.call(user_account, text: 'Test')
      ReblogService.new.call(bob_account, first_status)

      message = streaming_client.wait_for_message

      expect(message).to include(
        event: 'notification',
        stream: ['user:notification']
      )
    end
  end
end
