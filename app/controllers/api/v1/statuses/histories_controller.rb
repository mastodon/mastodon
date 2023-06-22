# frozen_string_literal: true

class Api::V1::Statuses::HistoriesController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:statuses' }
  before_action :set_status

  def show
    render json: status_edits, each_serializer: REST::StatusEditSerializer
  end

  private

  def status_edits
    @status.edits.includes(:account, status: [:account]).to_a.presence || [@status.build_snapshot(at_time: @status.edited_at || @status.created_at)]
  end

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
