# frozen_string_literal: true

class Api::V1::Apps::CredentialsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }

  def show
    render json: doorkeeper_token.application, serializer: REST::ApplicationSerializer, fields: %i(name website vapid_key)
  end
end
