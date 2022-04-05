# frozen_string_literal: true

class ActivityPub::ContextsController < ActivityPub::BaseController
  before_action :set_conversation

  def show
    expires_in 3.minutes, public: public_fetch_mode?
    render_with_cache json: @conversation, serializer: ActivityPub::ContextSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  private

  def set_conversation
    @conversation = Conversation.local.find(params[:id])
  end
end
