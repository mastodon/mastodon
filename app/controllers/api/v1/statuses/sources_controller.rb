# frozen_string_literal: true

class Api::V1::Statuses::SourcesController < Api::V1::Statuses::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }

  def show
    render json: @status, serializer: REST::StatusSourceSerializer
  end
end
