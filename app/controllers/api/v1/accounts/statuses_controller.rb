# frozen_string_literal: true

class Api::V1::Accounts::StatusesController < Api::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }
  before_action :set_account

  after_action :insert_pagination_headers, unless: -> { truthy_param?(:pinned) }

  def index
    @statuses = load_statuses
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id)
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def load_statuses
    @account.suspended? ? [] : cached_account_statuses
  end

  def cached_account_statuses
    statuses = truthy_param?(:pinned) ? pinned_scope : permitted_account_statuses

    statuses.merge!(only_media_scope) if truthy_param?(:only_media)
    statuses.merge!(no_replies_scope) if truthy_param?(:exclude_replies)
    statuses.merge!(no_reblogs_scope) if truthy_param?(:exclude_reblogs)
    statuses.merge!(hashtag_scope)    if params[:tagged].present?

    cache_collection_paginated_by_id(
      statuses,
      Status,
      limit_param(DEFAULT_STATUSES_LIMIT),
      params_slice(:max_id, :since_id, :min_id)
    )
  end

  def permitted_account_statuses
    @account.statuses.permitted_for(@account, current_account)
  end

  def only_media_scope
    Status.joins(:media_attachments).merge(@account.media_attachments.reorder(nil)).group(:id)
  end

  def pinned_scope
    return Status.none if @account.blocking?(current_account)

    @account.pinned_statuses
  end

  def no_replies_scope
    Status.without_replies
  end

  def no_reblogs_scope
    Status.without_reblogs
  end

  def hashtag_scope
    tag = Tag.find_normalized(params[:tagged])

    if tag
      Status.tagged_with(tag.id)
    else
      Status.none
    end
  end

  def pagination_params(core_params)
    params.slice(:limit, :only_media, :exclude_replies).permit(:limit, :only_media, :exclude_replies).merge(core_params)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    if records_continue?
      api_v1_account_statuses_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @statuses.empty?
      api_v1_account_statuses_url pagination_params(min_id: pagination_since_id)
    end
  end

  def records_continue?
    @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)
  end

  def pagination_max_id
    @statuses.last.id
  end

  def pagination_since_id
    @statuses.first.id
  end
end
