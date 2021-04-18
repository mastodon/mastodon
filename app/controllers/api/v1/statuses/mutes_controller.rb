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

  private

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    # Reraise in order to get a 404 instead of a 403 error code
    raise ActiveRecord::RecordNotFound
  end

  def set_conversation
    @conversation = @status.conversation
    raise Mastodon::ValidationError if @conversation.nil?
  end
end
