# frozen_string_literal: true

class AccountsController < ApplicationController
  PAGE_SIZE     = 20
  PAGE_SIZE_MAX = 200

  include AccountControllerConcern
  include SignatureAuthentication

  before_action :require_account_signature!, if: -> { request.format == :json && authorized_fetch_mode? }
  before_action :set_cache_headers

  skip_around_action :set_locale, if: -> { %i(json rss).include?(request.format&.to_sym) }
  skip_before_action :require_functional!, unless: :whitelist_mode?

  def show
    respond_to do |format|
      format.html do
        expires_in 0, public: true unless user_signed_in?

        @rss_url = rss_url
      end

      format.rss do
        expires_in 1.minute, public: true

        limit     = params[:limit].present? ? [params[:limit].to_i, PAGE_SIZE_MAX].min : PAGE_SIZE
        @statuses = filtered_statuses.without_reblogs.limit(limit)
        @statuses = cache_collection(@statuses, Status)
      end

      format.json do
        expires_in 3.minutes, public: !(authorized_fetch_mode? && signed_request_account.present?)
        render_with_cache json: @account, content_type: 'application/activity+json', serializer: ActivityPub::ActorSerializer, adapter: ActivityPub::Adapter
      end
    end
  end

  private

  def filtered_statuses
    default_statuses.tap do |statuses|
      statuses.merge!(hashtag_scope)    if tag_requested?
      statuses.merge!(only_media_scope) if media_requested?
      statuses.merge!(no_replies_scope) unless replies_requested?
    end
  end

  def default_statuses
    @account.statuses.where(visibility: %i(public unlisted))
  end

  def only_media_scope
    Status.joins(:media_attachments).merge(@account.media_attachments.reorder(nil)).group(:id)
  end

  def no_replies_scope
    Status.without_replies
  end

  def hashtag_scope
    tag = Tag.find_normalized(params[:tag])

    if tag
      Status.tagged_with(tag.id)
    else
      Status.none
    end
  end

  def username_param
    params[:username]
  end

  def skip_temporary_suspension_response?
    request.format == :json
  end

  def rss_url
    if tag_requested?
      short_account_tag_url(@account, params[:tag], format: 'rss')
    else
      short_account_url(@account, format: 'rss')
    end
  end

  def media_requested?
    request.path.split('.').first.end_with?('/media') && !tag_requested?
  end

  def replies_requested?
    request.path.split('.').first.end_with?('/with_replies') && !tag_requested?
  end

  def tag_requested?
    request.path.split('.').first.end_with?(Addressable::URI.parse("/tagged/#{params[:tag]}").normalize)
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
end
