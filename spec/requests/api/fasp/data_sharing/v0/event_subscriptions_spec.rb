# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Fasp::DataSharing::V0::EventSubscriptions', feature: :fasp do
  include ProviderRequestHelper

  describe 'POST /api/fasp/data_sharing/v0/event_subscriptions' do
    let(:provider) { Fabricate(:fasp_provider) }

    context 'with valid parameters' do
      it 'creates a new subscription' do
        params = { category: 'content', subscriptionType: 'lifecycle', maxBatchSize: 10 }
        headers = request_authentication_headers(provider,
                                                 url: api_fasp_data_sharing_v0_event_subscriptions_url,
                                                 method: :post,
                                                 body: params)

        expect do
          post api_fasp_data_sharing_v0_event_subscriptions_path, headers:, params:, as: :json
        end.to change(Fasp::Subscription, :count).by(1)
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a subscription' do
        params = { category: 'unknown' }
        headers = request_authentication_headers(provider,
                                                 url: api_fasp_data_sharing_v0_event_subscriptions_url,
                                                 method: :post,
                                                 body: params)

        expect do
          post api_fasp_data_sharing_v0_event_subscriptions_path, headers:, params:, as: :json
        end.to_not change(Fasp::Subscription, :count)
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /api/fasp/data_sharing/v0/event_subscriptions/:id' do
    let(:subscription) { Fabricate(:fasp_subscription) }
    let(:provider) { subscription.fasp_provider }

    it 'deletes the subscription' do
      headers = request_authentication_headers(provider,
                                               url: api_fasp_data_sharing_v0_event_subscription_url(subscription),
                                               method: :delete)

      expect do
        delete api_fasp_data_sharing_v0_event_subscription_path(subscription), headers:, as: :json
      end.to change(Fasp::Subscription, :count).by(-1)
      expect(response).to have_http_status(204)
    end
  end
end
