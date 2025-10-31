# frozen_string_literal: true

class Settings::LoginActivitiesController < Settings::BaseController
  skip_before_action :check_self_destruct!
  skip_before_action :require_functional!

  def index
    @login_activities = current_user.login_activities.order(id: :desc).page(params[:page])
  end
end
