# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 Push Subscriptions' do
  let(:user) { Fabricate(:user) }
  let(:create_payload) do
    {
      subscription: {
        endpoint: 'https://fcm.googleapis.com/fcm/send/fiuH06a27qE:APA91bHnSiGcLwdaxdyqVXNDR9w1NlztsHb6lyt5WDKOC_Z_Q8BlFxQoR8tWFSXUIDdkyw0EdvxTu63iqamSaqVSevW5LfoFwojws8XYDXv_NRRLH6vo2CdgiN4jgHv5VLt2A8ah6lUX',
        keys: {
          p256dh: 'BEm_a0bdPDhf0SOsrnB2-ategf1hHoCnpXgQsFj5JCkcoMrMt2WHoPfEYOYPzOIs9mZE8ZUaD7VA5vouy0kEkr8=',
          auth: 'eH_C8rq2raXqlcBVDa1gLg==',
        },
      },
    }.with_indifferent_access
  end
  let(:alerts_payload) do
    {
      data: {
        policy: 'all',

        alerts: {
          follow: true,
          follow_request: true,
          favourite: false,
          reblog: true,
          mention: false,
          poll: true,
          status: false,
        },
      },
    }.with_indifferent_access
  end
  let(:scopes) { 'push' }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'POST /api/v1/push/subscription' do
    before do
      post '/api/v1/push/subscription', params: create_payload, headers: headers
    end

    it 'saves push subscriptions' do
      push_subscription = Web::PushSubscription.find_by(endpoint: create_payload[:subscription][:endpoint])

      expect(push_subscription.endpoint).to eq(create_payload[:subscription][:endpoint])
      expect(push_subscription.key_p256dh).to eq(create_payload[:subscription][:keys][:p256dh])
      expect(push_subscription.key_auth).to eq(create_payload[:subscription][:keys][:auth])
      expect(push_subscription.user_id).to eq user.id
      expect(push_subscription.access_token_id).to eq token.id
    end

    it 'replaces old subscription on repeat calls' do
      post '/api/v1/push/subscription', params: create_payload, headers: headers

      expect(Web::PushSubscription.where(endpoint: create_payload[:subscription][:endpoint]).count).to eq 1
    end

    it 'returns the expected JSON' do
      expect(body_as_json.with_indifferent_access)
        .to include(
          { endpoint: create_payload[:subscription][:endpoint], alerts: {}, policy: 'all' }
        )
    end
  end

  describe 'PUT /api/v1/push/subscription' do
    before do
      post '/api/v1/push/subscription', params: create_payload, headers: headers
      put '/api/v1/push/subscription', params: alerts_payload, headers: headers
    end

    it 'changes alert settings' do
      push_subscription = Web::PushSubscription.find_by(endpoint: create_payload[:subscription][:endpoint])

      expect(push_subscription.data['policy']).to eq(alerts_payload[:data][:policy])

      %w(follow follow_request favourite reblog mention poll status).each do |type|
        expect(push_subscription.data['alerts'][type]).to eq(alerts_payload[:data][:alerts][type.to_sym].to_s)
      end
    end

    it 'returns the expected JSON' do
      expect(body_as_json.with_indifferent_access)
        .to include(
          { endpoint: create_payload[:subscription][:endpoint], alerts: alerts_payload[:data][:alerts], policy: alerts_payload[:data][:policy] }
        )
    end
  end

  describe 'DELETE /api/v1/push/subscription' do
    before do
      post '/api/v1/push/subscription', params: create_payload, headers: headers
      delete '/api/v1/push/subscription', headers: headers
    end

    it 'removes the subscription' do
      expect(Web::PushSubscription.find_by(endpoint: create_payload[:subscription][:endpoint])).to be_nil
    end
  end
end
