# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Fasp::Debug::V0::Callback::Responses', feature: :fasp do
  include ProviderRequestHelper

  describe 'POST /api/fasp/debug/v0/callback/responses' do
    let(:provider) { Fabricate(:debug_fasp) }

    it 'create a record of the callback' do
      payload = { test: 'call' }
      headers = request_authentication_headers(provider,
                                               url: api_fasp_debug_v0_callback_responses_url,
                                               method: :post,
                                               body: payload)

      expect do
        post api_fasp_debug_v0_callback_responses_path, headers:, params: payload, as: :json
      end.to change(Fasp::DebugCallback, :count).by(1)
      expect(response).to have_http_status(201)

      debug_callback = Fasp::DebugCallback.last
      expect(debug_callback.fasp_provider).to eq provider
      expect(debug_callback.request_body).to eq '{"test":"call"}'
    end
  end
end
