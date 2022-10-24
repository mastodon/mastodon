# frozen_string_literal: true

class ActivityPub::WallsController < ActivityPub::BaseController
  LIMIT = 20

  include SignatureVerification
  include GroupOwnedConcern

  before_action :require_account_signature!, if: :authorized_fetch_mode?
  before_action :set_statuses
  before_action :set_cache_headers

  def show
    if page_requested?
      expires_in(1.minute, public: public_fetch_mode? && signed_request_account.nil?)
    else
      expires_in(3.minutes, public: public_fetch_mode?)
    end
    render json: wall_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  private

  def wall_presenter
    if page_requested?
      ActivityPub::CollectionPresenter.new(
        id: wall_url(**page_params),
        type: :ordered,
        part_of: wall_url,
        prev: prev_page,
        next: next_page,
        items: @statuses.map { |status| status.local? ? status : status.uri }
      )
    else
      ActivityPub::CollectionPresenter.new(
        id: wall_url,
        type: :ordered,
        size: @group.statuses_count,
        first: wall_url(page: true),
        last: wall_url(page: true, min_id: 0)
      )
    end
  end

  def wall_url(**kwargs)
    group_wall_url(@group, **kwargs)
  end

  def next_page
    wall_url(page: true, max_id: @statuses.last.id) if @statuses.size == LIMIT
  end

  def prev_page
    wall_url(page: true, min_id: @statuses.first.id) unless @statuses.empty?
  end

  def set_statuses
    return unless page_requested?

    @statuses = cache_collection_paginated_by_id(
      @group.statuses.approved,
      Status,
      LIMIT,
      params_slice(:max_id, :min_id, :since_id)
    )
  end

  def page_requested?
    truthy_param?(:page)
  end

  def page_params
    { page: true, max_id: params[:max_id], min_id: params[:min_id] }.compact
  end

  def set_cache_headers
    response.headers['Vary'] = 'Signature' if authorized_fetch_mode? || page_requested?
  end
end
