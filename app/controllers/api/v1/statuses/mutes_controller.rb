# frozen_string_literal: true

class Api::V1::Statuses::MutesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:mutes' }
  before_action :require_user!
  before_action :set_status
  before_action :set_conversation

  def create
    current_account.mute_conversation!(@conversation)
    @mutes_map = { @conversation.id => true }

    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    current_account.unmute_conversation!(@conversation)
    @mutes_map = { @conversation.id => false }

    render json: @status, serializer: REST::StatusSerializer
  end

  def clear_notifications
    current_account.notifications.where(activity_type: 'Mention').joins(mention: :status)
                   .where(status: { in_reply_to_id: params[:status_id] }).destroy_all
    current_account.notifications.where(activity_type: 'Status').joins(:status)
                   .where(status: { reblog_of_id: params[:status_id] }).destroy_all
    current_account.notifications.where(activity_type: 'Favourite').joins(:favourite)
                   .where(favourite: { status_id: params[:status_id] }).destroy_all
    render_empty
  end

  private

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end

  def set_conversation
    @conversation = @status.conversation
    raise Mastodon::ValidationError if @conversation.nil?
  end
end
