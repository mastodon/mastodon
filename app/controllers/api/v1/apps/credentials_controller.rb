# frozen_string_literal: true

class Api::V1::Apps::CredentialsController < Api::BaseController
  def show
    return doorkeeper_render_error unless valid_doorkeeper_token?

    render json: doorkeeper_token.application, serializer: REST::ApplicationSerializer
  end
end
