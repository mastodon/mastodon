# frozen_string_literal: true

class Settings::LoginActivitiesController < Settings::BaseController
  skip_before_action :check_self_destruct!
  skip_before_action :require_functional!

  def index
    @login_activities = LoginActivity.where(user: current_user).order(id: :desc).page(params[:page])
  end
end
