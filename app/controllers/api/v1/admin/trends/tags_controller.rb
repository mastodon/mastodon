# frozen_string_literal: true

class Api::V1::Admin::Trends::TagsController < Api::V1::Trends::TagsController
  before_action -> { authorize_if_got_token! :'admin:read' }

  def index
    if current_user&.can?(:manage_taxonomies)
      render json: @tags, each_serializer: REST::Admin::TagSerializer
    else
      super
    end
  end

  def update
    raise Mastodon::NotPermittedError unless current_user&.can?(:manage_taxonomies)

    tag = Tag.find(params[:id])
    tag.update(tag_params.merge(reviewed_at: Time.now.utc))
    render json: tag, serializer: REST::Admin::TagSerializer
  end

  def approve
    raise Mastodon::NotPermittedError unless current_user&.can?(:manage_taxonomies)

    tag = Tag.find(params[:id])
    tag.update(trendable: true, reviewed_at: Time.now.utc)
    render json: tag, serializer: REST::Admin::TagSerializer
  end

  def reject
    raise Mastodon::NotPermittedError unless current_user&.can?(:manage_taxonomies)

    tag = Tag.find(params[:id])
    tag.update(trendable: false, reviewed_at: Time.now.utc)
    render json: tag, serializer: REST::Admin::TagSerializer
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :display_name, :trendable, :usable, :listable)
  end

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
