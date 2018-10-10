# frozen_string_literal: true

class Api::V1::ConversationsController < Api::BaseController
  LIMIT = 20

  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }
  before_action :require_user!
  after_action :insert_pagination_headers

  respond_to :json

  def index
    @conversations = paginated_conversations
    render json: @conversations, each_serializer: REST::ConversationSerializer
  end

  private

  def paginated_conversations
    AccountConversation.where(account: current_account)
                       .paginate_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    if records_continue?
      api_v1_conversations_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @conversations.empty?
      api_v1_conversations_url pagination_params(min_id: pagination_since_id)
    end
  end

  def pagination_max_id
    @conversations.last.last_status_id
  end

  def pagination_since_id
    @conversations.first.last_status_id
  end

  def records_continue?
    @conversations.size == limit_param(LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
