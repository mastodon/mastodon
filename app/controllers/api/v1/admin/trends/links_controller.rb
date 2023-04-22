# frozen_string_literal: true

class Api::V1::Admin::Trends::LinksController < Api::V1::Trends::LinksController
  include Authorization

  before_action -> { authorize_if_got_token! :'admin:read' }, only: :index
  before_action -> { authorize_if_got_token! :'admin:write' }, except: :index

  after_action :verify_authorized, except: :index

  def index
    if current_user&.can?(:manage_taxonomies)
      render json: @links, each_serializer: REST::Admin::Trends::LinkSerializer
    else
      super
    end
  end

  def approve
    authorize :preview_card, :review?

    link = PreviewCard.find(params[:id])
    link.update(trendable: true)
    render json: link, serializer: REST::Admin::Trends::LinkSerializer
  end

  def reject
    authorize :preview_card, :review?

    link = PreviewCard.find(params[:id])
    link.update(trendable: false)
    render json: link, serializer: REST::Admin::Trends::LinkSerializer
  end

  private

  def enabled?
    super || current_user&.can?(:manage_taxonomies)
  end

  def links_from_trends
    if current_user&.can?(:manage_taxonomies)
      Trends.links.query
    else
      super
    end
  end
end
