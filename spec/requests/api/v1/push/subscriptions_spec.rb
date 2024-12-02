# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Push Subscriptions' do
  let(:user) { Fabricate(:user) }
  let(:endpoint) { 'https://fcm.googleapis.com/fcm/send/fiuH06a27qE:APA91bHnSiGcLwdaxdyqVXNDR9w1NlztsHb6lyt5WDKOC_Z_Q8BlFxQoR8tWFSXUIDdkyw0EdvxTu63iqamSaqVSevW5LfoFwojws8XYDXv_NRRLH6vo2CdgiN4jgHv5VLt2A8ah6lUX' }
  let(:keys) do
    {
      p256dh: 'BEm_a0bdPDhf0SOsrnB2-ategf1hHoCnpXgQsFj5JCkcoMrMt2WHoPfEYOYPzOIs9mZE8ZUaD7VA5vouy0kEkr8=',
      auth: 'eH_C8rq2raXqlcBVDa1gLg==',
    }
  end
  let(:create_payload) do
    {
      subscription: {
        endpoint: endpoint,
        keys: keys,
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

  shared_examples 'validation error' do
    it 'returns a validation error' do
      subject

      expect(response).to have_http_status(422)
      expect(response.content_type)
        .to start_with('application/json')
      expect(endpoint_push_subscriptions.count).to eq(0)
      expect(endpoint_push_subscription).to be_nil
    end
  end

  describe 'POST /api/v1/push/subscription' do
    subject { post '/api/v1/push/subscription', params: create_payload, headers: headers }

    it 'saves push subscriptions and returns expected JSON' do
      subject

      expect(endpoint_push_subscription)
        .to have_attributes(
          endpoint: eq(create_payload[:subscription][:endpoint]),
          key_p256dh: eq(create_payload[:subscription][:keys][:p256dh]),
          key_auth: eq(create_payload[:subscription][:keys][:auth]),
          user_id: eq(user.id),
          access_token_id: eq(token.id)
        )

      expect(response.parsed_body.with_indifferent_access)
        .to include(
          { endpoint: create_payload[:subscription][:endpoint], alerts: {}, policy: 'all' }
        )
    end

    it 'replaces old subscription on repeat calls' do
      2.times { subject }

      expect(endpoint_push_subscriptions.count)
        .to eq(1)
    end

    context 'with invalid endpoint URL' do
      let(:endpoint) { 'app://example.foo' }

      it_behaves_like 'validation error'
    end

    context 'with invalid p256dh key' do
      let(:keys) do
        {
          p256dh: 'BEm_invalidf0SOsrnB2-ategf1hHoCnpXgQsFj5JCkcoMrMt2WHoPfEYOYPzOIs9mZE8ZUaD7VA5vouy0kEkr8=',
          auth: 'eH_C8rq2raXqlcBVDa1gLg==',
        }
      end

      it_behaves_like 'validation error'
    end

    context 'with invalid base64 p256dh key' do
      let(:keys) do
        {
          p256dh: 'not base64',
          auth: 'eH_C8rq2raXqlcBVDa1gLg==',
        }
      end

      it_behaves_like 'validation error'
    end
  end

  describe 'PUT /api/v1/push/subscription' do
    subject { put '/api/v1/push/subscription', params: alerts_payload, headers: headers }

    before { create_subscription_with_token }

    it 'changes data policy and alert settings and returns expected JSON' do
      expect { subject }
        .to change { endpoint_push_subscription.reload.data }
        .from(nil)
        .to(include('policy' => alerts_payload[:data][:policy]))

      %w(follow follow_request favourite reblog mention poll status).each do |type|
        expect(endpoint_push_subscription.data['alerts']).to include(
          type.to_s => eq(alerts_payload[:data][:alerts][type.to_sym].to_s)
        )
      end

      expect(response.parsed_body.with_indifferent_access)
        .to include(
          endpoint: create_payload[:subscription][:endpoint],
          alerts: alerts_payload[:data][:alerts],
          policy: alerts_payload[:data][:policy]
        )
    end
  end

  describe 'GET /api/v1/push/subscription' do
    subject { get '/api/v1/push/subscription', headers: headers }

    before { create_subscription_with_token }

    it 'shows subscription details' do
      subject

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to include(endpoint: endpoint)
    end
  end

  describe 'DELETE /api/v1/push/subscription' do
    subject { delete '/api/v1/push/subscription', headers: headers }

    before { create_subscription_with_token }

    it 'removes the subscription' do
      expect { subject }
        .to change { endpoint_push_subscription }.to(nil)
    end
  end

  private

  def endpoint_push_subscriptions
    Web::PushSubscription.where(
      endpoint: create_payload[:subscription][:endpoint]
    )
  end

  def endpoint_push_subscription
    endpoint_push_subscriptions.first
  end

  def create_subscription_with_token
    Fabricate(
      :web_push_subscription,
      endpoint: create_payload[:subscription][:endpoint],
      access_token_id: token.id
    )
  end
end
