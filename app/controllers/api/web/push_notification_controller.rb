# frozen_string_literal: true

class Api::Web::WebPushNotificationsController < ApiController
  respond_to :json

  before_action :require_user!

  def update
    web_notification.data = params[:data]
    web_notification.save!

    render_empty
  end

  private

  def web_notification
    @_web_push_notification ||= WebPushNotifications.where(user: current_user).first_or_initialize(user: current_user)
  end
end
