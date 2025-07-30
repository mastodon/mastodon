# frozen_string_literal: true

class Api::V1::Apps::CredentialsController < Api::BaseController
  before_action :verify_doorkeeper_token

  def show
    render json: doorkeeper_token.application, serializer: REST::ApplicationSerializer
  end

  private

  def verify_doorkeeper_token
    doorkeeper_render_error unless valid_doorkeeper_token?
  end
end
