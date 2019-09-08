# frozen_string_literal: true

class Api::V1::FeaturedTags::SuggestionsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:featured_tags' }, only: [:index]

  before_action :require_user!

  respond_to :json

  def index
    most_used_tags = Tag.most_used(current_account).where.not(id: current_account.featured_tags).limit(10)
    render json: most_used_tags, each_serializer: REST::TagSerializer
  end
end
