# frozen_string_literal: true

class GroupsController < ApplicationController
  PAGE_SIZE     = 20
  PAGE_SIZE_MAX = 200

  include WebAppControllerConcern
  include GroupOwnedConcern
  include SignatureAuthentication
  include Authorization

  before_action :require_account_signature!, if: -> { request.format == :json && authorized_fetch_mode? }
  before_action :set_instance_presenter
  before_action :set_cache_headers

  skip_around_action :set_locale, if: -> { request.format == :json }
  skip_before_action :require_functional!, only: :show, unless: :whitelist_mode?

  def show
    respond_to do |format|
      format.html do
        expires_in 0, public: true unless user_signed_in?
      end

      format.json do
        expires_in 3.minutes, public: !(authorized_fetch_mode? && signed_request_account.present?)
        render_with_cache json: @group, content_type: 'application/activity+json', serializer: ActivityPub::GroupActorSerializer, adapter: ActivityPub::Adapter
      end
    end
  end

  private

  def group_id_param
    params[:id]
  end

  def skip_temporary_suspension_response?
    request.format == :json
  end

  def filtered_statuses
    default_statuses
  end

  def default_statuses
    @group.statuses.approved
  end

  def older_url
    pagination_url(max_id: @statuses.last.id)
  end

  def newer_url
    pagination_url(min_id: @statuses.first.id)
  end

  def pagination_url(max_id: nil, min_id: nil)
    group_url(@group, max_id: max_id, min_id: min_id)
  end

  def cached_filtered_status_page
    cache_collection_paginated_by_id(
      filtered_statuses,
      Status,
      PAGE_SIZE,
      params_slice(:max_id, :min_id, :since_id)
    )
  end

  def params_slice(*keys)
    params.slice(*keys).permit(*keys)
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
