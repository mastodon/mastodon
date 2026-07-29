# frozen_string_literal: true

class Api::V1::Accounts::FeaturedTagsController < Api::V1::Accounts::BaseController
  before_action :set_account
  before_action :set_featured_tags

  respond_to :json

  def index
    render json: @featured_tags, each_serializer: REST::FeaturedTagSerializer
  end

  private

  def set_featured_tags
    @featured_tags = @account.unavailable? ? [] : @account.featured_tags
  end
end
