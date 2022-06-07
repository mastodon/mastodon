# frozen_string_literal: true

class Api::V1::Admin::Trends::TagsController < Api::BaseController
  protect_from_forgery with: :exception

  before_action -> { authorize_if_got_token! :'admin:read' }
  before_action :require_staff!
  before_action :set_tags

  def index
    render json: @tags, each_serializer: REST::Admin::TagSerializer
  end

  private

  def set_tags
    @tags = Trends.tags.query.limit(limit_param(10))
  end
end
