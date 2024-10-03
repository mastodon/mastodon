# frozen_string_literal: true

class Api::V1::Statuses::BaseController < Api::BaseController
  include Authorization

  before_action :set_status

  private

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
