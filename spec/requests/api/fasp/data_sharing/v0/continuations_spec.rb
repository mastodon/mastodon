# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Fasp::DataSharing::V0::Continuations', feature: :fasp do
  include ProviderRequestHelper

  describe 'POST /api/fasp/data_sharing/v0/backfill_requests/:id/continuations' do
    let(:backfill_request) { Fabricate(:fasp_backfill_request) }
    let(:provider) { backfill_request.fasp_provider }

    it 'queues a job to continue the given backfill request' do
      headers = request_authentication_headers(provider,
                                               url: api_fasp_data_sharing_v0_backfill_request_continuation_url(backfill_request),
                                               method: :post)

      post api_fasp_data_sharing_v0_backfill_request_continuation_path(backfill_request), headers:, as: :json
      expect(response).to have_http_status(204)
      expect(Fasp::BackfillWorker).to have_enqueued_sidekiq_job(backfill_request.id)
    end
  end
end
