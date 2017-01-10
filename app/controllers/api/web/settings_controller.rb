# frozen_string_literal: true

class Api::Web::SettingsController < ApiController
  respond_to :json

  before_action :require_user!

  def update
    setting      = ::Web::Setting.where(user: current_user).first_or_initialize(user: current_user)
    setting.data = params[:data]
    setting.save!

    render_empty
  end
end
