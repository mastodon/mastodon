# frozen_string_literal: true

class Api::V1::Statuses::MutesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write }
  before_action :require_user!
  before_action :set_status
  before_action :set_conversation

  respond_to :json

  def create
    current_account.mute_conversation!(@conversation)
    @mutes_map = { @conversation.id => true }

    render 'api/v1/statuses/show'
  end

  def destroy
    current_account.unmute_conversation!(@conversation)
    @mutes_map = { @conversation.id => false }

    render 'api/v1/statuses/show'
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
