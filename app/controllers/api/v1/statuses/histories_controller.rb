# frozen_string_literal: true

class Api::V1::Statuses::HistoriesController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:statuses' }
  before_action :set_status

  def show
    cache_if_unauthenticated!
    render json: @status.edits.includes(:account, status: [:account]), each_serializer: REST::StatusEditSerializer
  end

  private

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
