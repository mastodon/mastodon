require 'rails_helper'

RSpec.describe Api::PushController, type: :controller do
  describe 'POST #update' do
    context 'with hub.mode=subscribe' do
      it 'creates a subscription' do
        service = double(call: ['', 202])
        allow(Pubsubhubbub::SubscribeService).to receive(:new).and_return(service)
        account = Fabricate(:account)
        account_topic_url = "https://#{Rails.configuration.x.local_domain}/users/#{account.username}.atom"
        post :update, params: {
          'hub.mode' => 'subscribe',
          'hub.topic' => account_topic_url,
          'hub.callback' => 'https://callback.host/api',
          'hub.lease_seconds' => '3600',
          'hub.secret' => 'as1234df',
        }

        expect(service).to have_received(:call).with(
          account,
          'https://callback.host/api',
          'as1234df',
          '3600',
          nil
        )
        expect(response).to have_http_status(202)
      end
    end

    context 'with hub.mode=unsubscribe' do
      it 'unsubscribes the account' do
        service = double(call: ['', 202])
        allow(Pubsubhubbub::UnsubscribeService).to receive(:new).and_return(service)
        account = Fabricate(:account)
        account_topic_url = "https://#{Rails.configuration.x.local_domain}/users/#{account.username}.atom"
        post :update, params: {
          'hub.mode' => 'unsubscribe',
          'hub.topic' => account_topic_url,
          'hub.callback' => 'https://callback.host/api',
        }

        expect(service).to have_received(:call).with(
          account,
          'https://callback.host/api',
        )
        expect(response).to have_http_status(202)
      end
    end

    context 'with unknown mode' do
      it 'returns an unknown mode error' do
        post :update, params: { 'hub.mode' => 'fake' }

        expect(response).to have_http_status(422)
        expect(response.body).to match(/Unknown mode/)
      end
    end
  end
end
