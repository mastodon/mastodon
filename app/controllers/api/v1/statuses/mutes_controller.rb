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

    return_source = params[:format] == "source" ? true : false
    render json: @status, serializer: REST::StatusSerializer, source_requested: return_source
  end

  def destroy
    current_account.unmute_conversation!(@conversation)
    @mutes_map = { @conversation.id => false }

    return_source = params[:format] == "source" ? true : false
    render json: @status, serializer: REST::StatusSerializer
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
