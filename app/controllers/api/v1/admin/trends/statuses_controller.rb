# frozen_string_literal: true

class Api::V1::Admin::Trends::StatusesController < Api::V1::Trends::StatusesController
  before_action -> { authorize_if_got_token! :'admin:read' }

  def index
    render json: @statuses, each_serializer: REST::Admin::Trends::StatusSerializer
  end

  def approve
    if current_user&.can?(:manage_taxonomies)
      status = Status.find(params[:id])
      status.update(trendable: true)
      render json: status, serializer: REST::Admin::Trends::StatusSerializer
    else
      raise Mastodon::NotPermittedError
    end
  end

  def reject
    if current_user&.can?(:manage_taxonomies)
      status = Status.find(params[:id])
      status.update(trendable: false)
      render json: status, serializer: REST::Admin::Trends::StatusSerializer
    else
      raise Mastodon::NotPermittedError
    end
  end

  private

  def enabled?
    super || current_user&.can?(:manage_taxonomies)
  end

  def statuses_from_trends
    if current_user&.can?(:manage_taxonomies)
      Trends.statuses.query
    else
      super
    end
  end
end
