# frozen_string_literal: true

class Api::Hello::EventController < Api::BaseController
  respond_to :json
  def log
    Rails.logger.info request.body.read
    head :ok
    # render status: 200
  end
end
