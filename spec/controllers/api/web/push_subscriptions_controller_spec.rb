# frozen_string_literal: true

require 'rails_helper'

describe Api::Web::PushSubscriptionsController do
  render_views

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
    }
  end

  let(:alerts_payload) do
    {
      data: {
        policy: 'all',

        alerts: {
          follow: true,
          follow_request: false,
          favourite: false,
          reblog: true,
          mention: false,
          poll: true,
          status: false,
        },
      },
    }
  end

  describe 'POST #create' do
    it 'saves push subscriptions' do
      sign_in(user)

      stub_request(:post, create_payload[:subscription][:endpoint]).to_return(status: 200)

      post :create, format: :json, params: create_payload

      user.reload

      push_subscription = Web::PushSubscription.find_by(endpoint: create_payload[:subscription][:endpoint])

      expect(push_subscription['endpoint']).to eq(create_payload[:subscription][:endpoint])
      expect(push_subscription['key_p256dh']).to eq(create_payload[:subscription][:keys][:p256dh])
      expect(push_subscription['key_auth']).to eq(create_payload[:subscription][:keys][:auth])
    end

    context 'with initial data' do
      it 'saves alert settings' do
        sign_in(user)

        stub_request(:post, create_payload[:subscription][:endpoint]).to_return(status: 200)

        post :create, format: :json, params: create_payload.merge(alerts_payload)

        push_subscription = Web::PushSubscription.find_by(endpoint: create_payload[:subscription][:endpoint])

        expect(push_subscription.data['policy']).to eq 'all'

        %w(follow follow_request favourite reblog mention poll status).each do |type|
          expect(push_subscription.data['alerts'][type]).to eq(alerts_payload[:data][:alerts][type.to_sym].to_s)
        end
      end
    end
  end

  describe 'PUT #update' do
    it 'changes alert settings' do
      sign_in(user)

      stub_request(:post, create_payload[:subscription][:endpoint]).to_return(status: 200)

      post :create, format: :json, params: create_payload

      alerts_payload[:id] = Web::PushSubscription.find_by(endpoint: create_payload[:subscription][:endpoint]).id

      put :update, format: :json, params: alerts_payload

      push_subscription = Web::PushSubscription.find_by(endpoint: create_payload[:subscription][:endpoint])

      expect(push_subscription.data['policy']).to eq 'all'

      %w(follow follow_request favourite reblog mention poll status).each do |type|
        expect(push_subscription.data['alerts'][type]).to eq(alerts_payload[:data][:alerts][type.to_sym].to_s)
      end
    end
  end
end
