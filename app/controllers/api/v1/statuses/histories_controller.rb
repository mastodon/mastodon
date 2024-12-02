# frozen_string_literal: true

class Api::V1::Statuses::HistoriesController < Api::V1::Statuses::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }

  def show
    cache_if_unauthenticated!
    render json: status_edits, each_serializer: REST::StatusEditSerializer
  end

  private

  def status_edits
    @status.edits.ordered.includes(:account, status: [:account]).to_a.presence || [@status.build_snapshot(at_time: @status.edited_at || @status.created_at)]
  end
end
