# frozen_string_literal: true

class Api::Fasp::DataSharing::V0::ContinuationsController < Api::Fasp::BaseController
  def create
    backfill_request = current_provider.fasp_backfill_requests.find(params[:backfill_request_id])
    Fasp::BackfillWorker.perform_async(backfill_request.id)

    head 204
  end
end
