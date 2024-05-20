# frozen_string_literal: true

class Api::V1::Admin::Trends::Links::PreviewCardProvidersController < Api::BaseController
  include Authorization

  LIMIT = 100

  before_action -> { authorize_if_got_token! :'admin:read' }, only: :index
  before_action -> { authorize_if_got_token! :'admin:write' }, except: :index
  before_action :set_providers, only: :index

  after_action :verify_authorized
  after_action :insert_pagination_headers, only: :index

  PAGINATION_PARAMS = %i(limit).freeze

  def index
    authorize :preview_card_provider, :index?

    render json: @providers, each_serializer: REST::Admin::Trends::Links::PreviewCardProviderSerializer
  end

  def approve
    authorize :preview_card_provider, :review?

    provider = PreviewCardProvider.find(params[:id])
    provider.update(trendable: true, reviewed_at: Time.now.utc)
    render json: provider, serializer: REST::Admin::Trends::Links::PreviewCardProviderSerializer
  end

  def reject
    authorize :preview_card_provider, :review?

    provider = PreviewCardProvider.find(params[:id])
    provider.update(trendable: false, reviewed_at: Time.now.utc)
    render json: provider, serializer: REST::Admin::Trends::Links::PreviewCardProviderSerializer
  end

  private

  def set_providers
    @providers = PreviewCardProvider.all.to_a_paginated_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def next_path
    api_v1_admin_trends_links_preview_card_providers_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v1_admin_trends_links_preview_card_providers_url(pagination_params(min_id: pagination_since_id)) unless @providers.empty?
  end

  def pagination_collection
    @providers
  end

  def records_continue?
    @providers.size == limit_param(LIMIT)
  end

  def pagination_params(core_params)
    params.slice(*PAGINATION_PARAMS).permit(*PAGINATION_PARAMS).merge(core_params)
  end
end
