# frozen_string_literal: true

class Api::Web::SettingsController < Api::Web::BaseController
  respond_to :json

  before_action :require_user!

  def update
    setting.data = params[:data]
    setting.save!

    render_empty
  end

  private

  def setting
    @_setting ||= ::Web::Setting.where(user: current_user).first_or_initialize(user: current_user)
  end
end
