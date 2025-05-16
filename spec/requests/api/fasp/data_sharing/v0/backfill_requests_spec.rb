# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Fasp::DataSharing::V0::BackfillRequests', feature: :fasp do
  include ProviderRequestHelper

  describe 'POST /api/fasp/data_sharing/v0/backfill_requests' do
    let(:provider) { Fabricate(:fasp_provider) }

    context 'with valid parameters' do
      it 'creates a new backfill request' do
        params = { category: 'content', maxCount: 10 }
        headers = request_authentication_headers(provider,
                                                 url: api_fasp_data_sharing_v0_backfill_requests_url,
                                                 method: :post,
                                                 body: params)

        expect do
          post api_fasp_data_sharing_v0_backfill_requests_path, headers:, params:, as: :json
        end.to change(Fasp::BackfillRequest, :count).by(1)
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a backfill request' do
        params = { category: 'unknown', maxCount: 10 }
        headers = request_authentication_headers(provider,
                                                 url: api_fasp_data_sharing_v0_backfill_requests_url,
                                                 method: :post,
                                                 body: params)

        expect do
          post api_fasp_data_sharing_v0_backfill_requests_path, headers:, params:, as: :json
        end.to_not change(Fasp::BackfillRequest, :count)
        expect(response).to have_http_status(422)
      end
    end
  end
end
