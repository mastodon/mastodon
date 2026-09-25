# frozen_string_literal: true

class Api::V1::Statuses::BaseController < Api::BaseController
  include Authorization

  before_action :set_status

  private

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    not_found
  else
    render json: { error: 'This operation is not allowed on reblogs' }, status: 400 if @status.reblog?
  end
end
