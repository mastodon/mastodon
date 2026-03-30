# frozen_string_literal: true

class ActivityPub::OutboxesController < ActivityPub::BaseController
  LIMIT = 20

  vary_by -> { 'Signature' if authorized_fetch_mode? || page_requested? }

  before_action :require_account_signature!, if: :authorized_fetch_mode?
  before_action :set_statuses

  def show
    if page_requested?
      expires_in(1.minute, public: public_fetch_mode? && signed_request_account.nil?)
    else
      expires_in(3.minutes, public: public_fetch_mode?)
    end

    render json: outbox_presenter, serializer: ActivityPub::OutboxSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  private

  def outbox_presenter
    if page_requested?
      ActivityPub::CollectionPresenter.new(
        id: outbox_url(**page_params),
        type: :ordered,
        part_of: outbox_url,
        prev: prev_page,
        next: next_page,
        items: @statuses
      )
    else
      ActivityPub::CollectionPresenter.new(
        id: outbox_url,
        type: :ordered,
        size: @account.statuses_count,
        first: outbox_url(page: true),
        last: outbox_url(page: true, min_id: 0)
      )
    end
  end

  def outbox_url(...)
    ActivityPub::TagManager.instance.outbox_uri_for(@account, ...)
  end

  def next_page
    outbox_url(page: true, max_id: @statuses.last.id) if @statuses.size == LIMIT
  end

  def prev_page
    outbox_url(page: true, min_id: @statuses.first.id) unless @statuses.empty?
  end

  def set_statuses
    return unless page_requested?

    @statuses = preload_collection_paginated_by_id(
      AccountStatusesFilter.new(@account, signed_request_account).results,
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

  def set_account
    return super if params[:account_username].present? || params[:account_id].present?

    @account = Account.representative
  end
end
