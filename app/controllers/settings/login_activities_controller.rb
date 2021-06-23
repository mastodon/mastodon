# frozen_string_literal: true

class Settings::LoginActivitiesController < Settings::BaseController
  def index
    @login_activities = LoginActivity.where(user: current_user).order(id: :desc).page(params[:page])
  end

  private

  def set_pack
    use_pack 'settings'
  end
end
