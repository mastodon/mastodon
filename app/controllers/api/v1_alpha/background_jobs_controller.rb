# frozen_string_literal: true

class Api::V1Alpha::BackgroundJobsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  def show
    background_job = BackgroundJob.find(params[:id])

    if background_job
      render json: background_job
    else
      not_found
    end
  end
end
