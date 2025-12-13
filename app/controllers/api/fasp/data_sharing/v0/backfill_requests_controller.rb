# frozen_string_literal: true

class Api::Fasp::DataSharing::V0::BackfillRequestsController < Api::Fasp::BaseController
  def create
    backfill_request = current_provider.fasp_backfill_requests.new(backfill_request_params)

    respond_to do |format|
      format.json do
        if backfill_request.save
          render json: { backfillRequest: { id: backfill_request.id } }, status: 201
        else
          head 422
        end
      end
    end
  end

  private

  def backfill_request_params
    params
      .permit(:category, :maxCount)
      .to_unsafe_h
      .transform_keys { |k| k.to_s.underscore }
  end
end
