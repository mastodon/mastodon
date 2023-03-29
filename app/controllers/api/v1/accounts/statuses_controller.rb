# frozen_string_literal: true

class Api::V1::Accounts::StatusesController < Api::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }
  before_action :set_account

  after_action :insert_pagination_headers, unless: -> { truthy_param?(:pinned) }

  def index
    @statuses = load_statuses
    return_source = params[:format] == "source" ? true : false
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id), source_requested: return_source
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def load_statuses
    @account.suspended? ? [] : cached_account_statuses
  end

  def cached_account_statuses
    cache_collection_paginated_by_id(
      AccountStatusesFilter.new(@account, current_account, params).results,
      Status,
      limit_param(DEFAULT_STATUSES_LIMIT),
      params_slice(:max_id, :since_id, :min_id)
    )
  end

  def pagination_params(core_params)
    params.slice(:limit, *AccountStatusesFilter::KEYS).permit(:limit, *AccountStatusesFilter::KEYS).merge(core_params)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_account_statuses_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_account_statuses_url pagination_params(min_id: pagination_since_id) unless @statuses.empty?
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
