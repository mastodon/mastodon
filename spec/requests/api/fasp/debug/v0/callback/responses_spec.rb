# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Fasp::Debug::V0::Callback::Responses', feature: :fasp do
  include ProviderRequestHelper

  describe 'POST /api/fasp/debug/v0/callback/responses' do
    subject do
      post api_fasp_debug_v0_callback_responses_path, headers:, params: payload, as: :json
    end

    let(:provider) { Fabricate(:confirmed_fasp) }
    let(:payload) { { test: 'call' } }
    let(:headers) do
      request_authentication_headers(provider,
                                     url: api_fasp_debug_v0_callback_responses_url,
                                     method: :post,
                                     body: payload)
    end

    it_behaves_like 'forbidden for unconfirmed provider'

    it 'create a record of the callback' do
      expect { subject }.to change(Fasp::DebugCallback, :count).by(1)
      expect(response).to have_http_status(201)

      debug_callback = Fasp::DebugCallback.last
      expect(debug_callback.fasp_provider).to eq provider
      expect(debug_callback.request_body).to eq '{"test":"call"}'
    end
  end
end
