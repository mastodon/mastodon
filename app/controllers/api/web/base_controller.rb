# frozen_string_literal: true

class Api::Web::BaseController < Api::BaseController
  protect_from_forgery with: :exception

  rescue_from ActionController::InvalidAuthenticityToken do
    render json: { error: "Can't verify CSRF token authenticity." }, status: 422
  end
end
