# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Web Push Subscriptions' do
  describe 'DELETE /api/web/push_subscriptions/:id' do
    subject { delete api_web_push_subscription_path(token) }

    let!(:web_push_subscription) do
      Fabricate(:web_push_subscription)
    end
    let(:token) do
      web_push_subscription.generate_token_for(:unsubscribe)
    end

    it 'deletes the subscription' do
      expect { subject }
        .to change(Web::PushSubscription, :count).by(-1)
    end
  end
end
