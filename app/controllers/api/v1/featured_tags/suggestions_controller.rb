# frozen_string_literal: true

class Api::V1::FeaturedTags::SuggestionsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, only: :index
  before_action :require_user!
  before_action :set_recently_used_tags, only: :index

  RECENT_TAGS_LIMIT = 10

  def index
    render json: @recently_used_tags, each_serializer: REST::TagSerializer, relationships: TagRelationshipsPresenter.new(@recently_used_tags, current_user&.account_id)
  end

  private

  def set_recently_used_tags
    @recently_used_tags = Tag.suggestions_for_account(current_account).limit(RECENT_TAGS_LIMIT)
  end
end
