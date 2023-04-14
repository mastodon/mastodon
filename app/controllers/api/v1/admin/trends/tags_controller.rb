# frozen_string_literal: true

class Api::V1::Admin::Trends::TagsController < Api::V1::Trends::TagsController
  include Authorization

  before_action -> { authorize_if_got_token! :'admin:read' }, only: :index
  before_action -> { authorize_if_got_token! :'admin:write' }, except: :index

  after_action :verify_authorized

  def index
    authorize :tag, :index?

    if current_user&.can?(:manage_taxonomies)
      render json: @tags, each_serializer: REST::Admin::TagSerializer
    else
      super
    end
  end

  def approve
    authorize :tag, :review?

    tag = Tag.find(params[:id])
    tag.update(trendable: true, reviewed_at: Time.now.utc)
    render json: tag, serializer: REST::Admin::TagSerializer
  end

  def reject
    authorize :tag, :review?

    tag = Tag.find(params[:id])
    tag.update(trendable: false, reviewed_at: Time.now.utc)
    render json: tag, serializer: REST::Admin::TagSerializer
  end

  private

  def enabled?
    super || current_user&.can?(:manage_taxonomies)
  end

  def tags_from_trends
    if current_user&.can?(:manage_taxonomies)
      Trends.tags.query
    else
      super
    end
  end
end
