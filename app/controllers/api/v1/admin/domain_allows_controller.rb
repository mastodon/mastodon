# frozen_string_literal: true

class Api::V1::Admin::DomainAllowsController < Api::BaseController
  include Authorization
  include AccountableConcern

  LIMIT = 100

  before_action -> { authorize_if_got_token! :'admin:read', :'admin:read:domain_allows' }, only: [:index, :show]
  before_action -> { authorize_if_got_token! :'admin:write', :'admin:write:domain_allows' }, except: [:index, :show]
  before_action :set_domain_allows, only: :index
  before_action :set_domain_allow, only: [:show, :destroy]

  after_action :verify_authorized
  after_action :insert_pagination_headers, only: :index

  PAGINATION_PARAMS = %i(limit).freeze

  def index
    authorize :domain_allow, :index?
    render json: @domain_allows, each_serializer: REST::Admin::DomainAllowSerializer
  end

  def show
    authorize @domain_allow, :show?
    render json: @domain_allow, serializer: REST::Admin::DomainAllowSerializer
  end

  def create
    authorize :domain_allow, :create?

    @domain_allow = DomainAllow.find_by(domain: resource_params[:domain])

    if @domain_allow.nil?
      @domain_allow = DomainAllow.create!(resource_params)
      log_action :create, @domain_allow
    end

    render json: @domain_allow, serializer: REST::Admin::DomainAllowSerializer
  end

  def destroy
    authorize @domain_allow, :destroy?
    UnallowDomainService.new.call(@domain_allow)
    log_action :destroy, @domain_allow
    render_empty
  end

  private

  def set_domain_allows
    @domain_allows = filtered_domain_allows.order(id: :desc).to_a_paginated_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def set_domain_allow
    @domain_allow = DomainAllow.find(params[:id])
  end

  def filtered_domain_allows
    # TODO: no filtering yet
    DomainAllow.all
  end

  def next_path
    api_v1_admin_domain_allows_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v1_admin_domain_allows_url(pagination_params(min_id: pagination_since_id)) unless @domain_allows.empty?
  end

  def pagination_collection
    @domain_allows
  end

  def records_continue?
    @domain_allows.size == limit_param(LIMIT)
  end

  def pagination_params(core_params)
    params.slice(*PAGINATION_PARAMS).permit(*PAGINATION_PARAMS).merge(core_params)
  end

  def resource_params
    params.permit(:domain)
  end
end
