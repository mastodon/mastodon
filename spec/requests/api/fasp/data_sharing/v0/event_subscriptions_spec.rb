# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Fasp::DataSharing::V0::EventSubscriptions', feature: :fasp do
  include ProviderRequestHelper

  describe 'POST /api/fasp/data_sharing/v0/event_subscriptions' do
    subject do
      post api_fasp_data_sharing_v0_event_subscriptions_path, headers:, params:, as: :json
    end

    let(:provider) { Fabricate(:confirmed_fasp) }
    let(:params) { { category: 'content', subscriptionType: 'lifecycle', maxBatchSize: 10 } }
    let(:headers) do
      request_authentication_headers(provider,
                                     url: api_fasp_data_sharing_v0_event_subscriptions_url,
                                     method: :post,
                                     body: params)
    end

    it_behaves_like 'forbidden for unconfirmed provider'

    context 'with valid parameters' do
      it 'creates a new subscription' do
        expect do
          subject
        end.to change(Fasp::Subscription, :count).by(1)
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid parameters' do
      let(:params) { { category: 'unknown' } }

      it 'does not create a subscription' do
        expect { subject }.to_not change(Fasp::Subscription, :count)
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /api/fasp/data_sharing/v0/event_subscriptions/:id' do
    subject do
      delete api_fasp_data_sharing_v0_event_subscription_path(subscription), headers:, as: :json
    end

    let(:provider) { Fabricate(:confirmed_fasp) }
    let!(:subscription) { Fabricate(:fasp_subscription, fasp_provider: provider) }
    let(:headers) do
      request_authentication_headers(provider,
                                     url: api_fasp_data_sharing_v0_event_subscription_url(subscription),
                                     method: :delete)
    end

    it_behaves_like 'forbidden for unconfirmed provider'

    it 'deletes the subscription' do
      expect { subject }.to change(Fasp::Subscription, :count).by(-1)
      expect(response).to have_http_status(204)
    end
  end
end
