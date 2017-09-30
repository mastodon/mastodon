# frozen_string_literal: true

class Api::V1::Apps::CredentialsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }

  respond_to :json

  def show
    render json: doorkeeper_token.application, serializer: REST::StatusSerializer::ApplicationSerializer
  end
end
