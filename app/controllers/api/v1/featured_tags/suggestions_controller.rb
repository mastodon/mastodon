# frozen_string_literal: true

class Api::V1::FeaturedTags::SuggestionsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, only: :index
  before_action :require_user!
  before_action :set_most_used_tags, only: :index

  def index
    render json: @most_used_tags, each_serializer: REST::TagSerializer
  end

  private

  def set_most_used_tags
    @most_used_tags = Tag.most_used(current_account).where.not(id: current_account.featured_tags).limit(10)
  end
end
