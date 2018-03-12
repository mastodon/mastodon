# frozen_string_literal: true

class Api::V1::Notifications::UnreadsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  def show
    render json: UnreadNotificationsPresenter.new(current_user), serializer: REST::UnreadNotificationsSerializer
  end

  def update
    current_user.update! last_read_notification_id: params[:last_read_id] if params.key? :last_read_id
    doorkeeper_token.update! reading_notifications: params[:reading] if params.key? :reading

    show
  end
end
