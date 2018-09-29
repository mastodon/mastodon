# frozen_string_literal: true

class Api::V1::ConversationsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }
  before_action :require_user!

  def index
    render json: conversations, each_serializer: REST::ConversationSerializer
  end

  private

  def conversations
    ConversationAccount.where(account: current_account).order(last_status_id: :desc)
  end
end
