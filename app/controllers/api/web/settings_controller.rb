# frozen_string_literal: true

class Api::Web::SettingsController < Api::Web::BaseController
  before_action :require_user!
  before_action :set_setting

  def update
    @setting.update!(data: params[:data])
    render_empty
  end

  private

  def set_setting
    @setting = ::Web::Setting.where(user: current_user).first_or_initialize(user: current_user)
  end
end
