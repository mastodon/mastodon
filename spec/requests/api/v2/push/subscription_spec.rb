# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V2 Push Subscriptions' do
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
        standard: standard,
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
  let(:standard) { '1' }
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

  describe 'GET /api/v2/push/subscription' do
    subject { get api_v2_push_subscription_path, headers: headers }

    context 'with a subscription' do
      let!(:subscription) { create_subscription_with_token }

      before { subscription }

      it 'shows subscription details' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to include(endpoint: endpoint)
      end

      it 'returns subscription.id as a string' do
        subject

        expect(response.parsed_body)
          .to include(id: subscription.id.to_s)
      end
    end

    context 'without a subscription' do
      it 'returns not found' do
        subject

        expect(response)
          .to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  def create_subscription_with_token
    Fabricate(
      :web_push_subscription,
      endpoint: create_payload[:subscription][:endpoint],
      access_token: token,
      user: user
    )
  end
end
