# frozen_string_literal: true

require 'rails_helper'

describe Api::Web::EmbedsController do
  render_views

  let(:user) { Fabricate(:user) }

  before { sign_in user }

  describe 'POST #create' do
    subject(:response) { post :create, params: { url: url } }
    subject(:body) { JSON.parse(response.body, symbolize_names: true) }

    context 'when successfully finds status' do
      let(:status) { Fabricate(:status) }
      let(:url) { "http://#{Rails.configuration.x.web_domain}/@#{status.account.username}/#{status.id}" }

      it 'returns a right response' do
        expect(response).to have_http_status :ok
        expect(body[:author_name]).to eq status.account.username
      end
    end

    context 'when fails to find status' do
      let(:url) { 'https://host.test/oembed.html' }
      let(:service_instance) { double('fetch_oembed_service') }

      before do
        allow(FetchOEmbedService).to receive(:new) { service_instance }
        allow(service_instance).to receive(:call) { call_result }
      end

      context 'when successfully fetching oembed' do
        let(:call_result) { { result: :ok } }

        it 'returns a right response' do
          expect(response).to have_http_status :ok
          expect(body[:result]).to eq 'ok'
        end
      end

      context 'when fails to fetch oembed' do
        let(:call_result) { nil }

        it 'returns a right response' do
          expect(response).to have_http_status :not_found
        end
      end
    end
  end
end
