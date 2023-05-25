# frozen_string_literal: true

class Api::V1::ConversationsController < Api::BaseController
  LIMIT = 20

  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:conversations' }, except: :index
  before_action :require_user!
  before_action :set_conversation, except: :index
  after_action :insert_pagination_headers, only: :index

  def index
    @conversations = paginated_conversations
    render json: @conversations, each_serializer: REST::ConversationSerializer, relationships: StatusRelationshipsPresenter.new(@conversations.map(&:last_status), current_user&.account_id)
  end

  def read
    @conversation.update!(unread: false)
    render json: @conversation, serializer: REST::ConversationSerializer
  end

  def destroy
    @conversation.destroy!
    render_empty
  end

  private

  def set_conversation
    @conversation = AccountConversation.where(account: current_account).find(params[:id])
  end

  def paginated_conversations
    AccountConversation.where(account: current_account)
                       .includes(
                         account: :account_stat,
                         last_status: [
                           :media_attachments,
                           :preview_cards,
                           :status_stat,
                           :tags,
                           {
                             active_mentions: [account: :account_stat],
                             account: :account_stat,
                           },
                         ]
                       )
                       .to_a_paginated_by_id(limit_param(LIMIT), **params_slice(:max_id, :since_id, :min_id))
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_conversations_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_conversations_url pagination_params(min_id: pagination_since_id) unless @conversations.empty?
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
