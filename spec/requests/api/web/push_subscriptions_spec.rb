# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Web Push Subscriptions' do
  describe 'DELETE /api/web/push_subscriptions/:id' do
    subject { delete api_web_push_subscription_path(token) }

    context 'when the subscription exists' do
      let!(:web_push_subscription) do
        Fabricate(:web_push_subscription)
      end
      let(:token) do
        web_push_subscription.generate_token_for(:unsubscribe)
      end

      it 'deletes the subscription' do
        expect { subject }
          .to change(Web::PushSubscription, :count).by(-1)

        expect(response).to have_http_status(200)
      end
    end

    context 'when the subscription does not exist' do
      let(:web_push_subscription) do
        Fabricate(:web_push_subscription)
      end
      let(:token) do
        web_push_subscription.generate_token_for(:unsubscribe)
      end

      before do
        token # memoize before destroying the record
        web_push_subscription.destroy!
      end

      it 'does nothing' do
        subject

        expect(response).to have_http_status(200)
      end
    end

    context 'when the token is invalid' do
      let(:token) { 'invalid--invalid' }

      it 'does nothing' do
        subject

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /api/web/push_subscriptions' do
    before { sign_in Fabricate :user }

    it 'gracefully handles invalid nested params' do
      post api_web_push_subscriptions_path, params: { subscription: 'invalid' }

      expect(response)
        .to have_http_status(400)
    end
  end

  describe 'PUT /api/web/push_subscriptions' do
    before { sign_in Fabricate :user }

    let(:subscription) { Fabricate :web_push_subscription }

    it 'gracefully handles invalid nested params' do
      put api_web_push_subscription_path(subscription), params: { data: 'invalid' }

      expect(response)
        .to have_http_status(400)
    end
  end
end
