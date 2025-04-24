# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Web::PushSubscriptionsController do
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
        standard: standard,
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
  let(:standard) { '1' }

  before do
    sign_in(user)

    stub_request(:post, create_payload[:subscription][:endpoint]).to_return(status: 200)
  end

  describe 'POST #create' do
    it 'saves push subscriptions' do
      post :create, format: :json, params: create_payload

      expect(response).to have_http_status(200)

      user.reload

      expect(created_push_subscription)
        .to have_attributes(
          endpoint: eq(create_payload[:subscription][:endpoint]),
          key_p256dh: eq(create_payload[:subscription][:keys][:p256dh]),
          key_auth: eq(create_payload[:subscription][:keys][:auth])
        )
        .and be_standard
      expect(user.session_activations.first.web_push_subscription).to eq(created_push_subscription)
    end

    context 'when standard is provided as false value' do
      let(:standard) { '0' }

      it 'saves push subscription with standard as false' do
        post :create, format: :json, params: create_payload

        expect(created_push_subscription)
          .to_not be_standard
      end
    end

    context 'with a user who has a session with a prior subscription' do
      let!(:prior_subscription) { Fabricate(:web_push_subscription, session_activation: user.session_activations.last) }

      it 'destroys prior subscription when creating new one' do
        post :create, format: :json, params: create_payload

        expect(response).to have_http_status(200)
        expect { prior_subscription.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with initial data' do
      it 'saves alert settings' do
        post :create, format: :json, params: create_payload.merge(alerts_payload)

        expect(response).to have_http_status(200)

        expect(created_push_subscription.data['policy']).to eq 'all'

        %w(follow follow_request favourite reblog mention poll status).each do |type|
          expect(created_push_subscription.data['alerts'][type]).to eq(alerts_payload[:data][:alerts][type.to_sym].to_s)
        end
      end
    end
  end

  describe 'PUT #update' do
    it 'changes alert settings' do
      post :create, format: :json, params: create_payload

      expect(response).to have_http_status(200)

      alerts_payload[:id] = created_push_subscription.id

      put :update, format: :json, params: alerts_payload

      expect(created_push_subscription.data['policy']).to eq 'all'

      %w(follow follow_request favourite reblog mention poll status).each do |type|
        expect(created_push_subscription.data['alerts'][type]).to eq(alerts_payload[:data][:alerts][type.to_sym].to_s)
      end
    end
  end

  def created_push_subscription
    Web::PushSubscription.find_by(endpoint: create_payload[:subscription][:endpoint])
  end
end
