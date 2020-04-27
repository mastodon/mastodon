# frozen_string_literal: true

class AccountsController < ApplicationController
  PAGE_SIZE = 20

  include AccountControllerConcern
  include SignatureAuthentication

  before_action :set_cache_headers
  before_action :set_body_classes

  skip_around_action :set_locale, if: -> { [:json, :rss].include?(request.format&.to_sym) }
  skip_before_action :require_functional!

  def show
    respond_to do |format|
      format.html do
        expires_in 0, public: true unless user_signed_in?

        @pinned_statuses   = []
        @endorsed_accounts = @account.endorsed_accounts.to_a.sample(4)
        @featured_hashtags = @account.featured_tags.order(statuses_count: :desc)

        if current_account && @account.blocking?(current_account)
          @statuses = []
          return
        end

        @pinned_statuses = cache_collection(@account.pinned_statuses, Status) if show_pinned_statuses?
        @statuses        = filtered_status_page(params)
        @statuses        = cache_collection(@statuses, Status)
        @rss_url         = rss_url

        unless @statuses.empty?
          @older_url = older_url if @statuses.last.id > filtered_statuses.last.id
          @newer_url = newer_url if @statuses.first.id < filtered_statuses.first.id
        end
      end

      format.rss do
        expires_in 1.minute, public: true

        @statuses = filtered_statuses.without_reblogs.without_replies.limit(PAGE_SIZE)
        @statuses = cache_collection(@statuses, Status)
        render xml: RSS::AccountSerializer.render(@account, @statuses, params[:tag])
      end

      format.json do
        expires_in 3.minutes, public: !(authorized_fetch_mode? && signed_request_account.present?)
        render_with_cache json: @account, content_type: 'application/activity+json', serializer: ActivityPub::ActorSerializer, adapter: ActivityPub::Adapter, fields: restrict_fields_to
      end
    end
  end

  private

  def set_body_classes
    @body_classes = 'with-modals'
  end

  def show_pinned_statuses?
    [replies_requested?, media_requested?, tag_requested?, params[:max_id].present?, params[:min_id].present?].none?
  end

  def filtered_statuses
    default_statuses.tap do |statuses|
      statuses.merge!(hashtag_scope)    if tag_requested?
      statuses.merge!(only_media_scope) if media_requested?
      statuses.merge!(no_replies_scope) unless replies_requested?
    end
  end

  def default_statuses
    @account.statuses.where(visibility: [:public, :unlisted])
  end

  def only_media_scope
    Status.where(id: account_media_status_ids)
  end

  def account_media_status_ids
    @account.media_attachments.attached.reorder(nil).select(:status_id).distinct
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

  def rss_url
    if tag_requested?
      short_account_tag_url(@account, params[:tag], format: 'rss')
    else
      short_account_url(@account, format: 'rss')
    end
  end

  def older_url
    pagination_url(max_id: @statuses.last.id)
  end

  def newer_url
    pagination_url(min_id: @statuses.first.id)
  end

  def pagination_url(max_id: nil, min_id: nil)
    if tag_requested?
      short_account_tag_url(@account, params[:tag], max_id: max_id, min_id: min_id)
    elsif media_requested?
      short_account_media_url(@account, max_id: max_id, min_id: min_id)
    elsif replies_requested?
      short_account_with_replies_url(@account, max_id: max_id, min_id: min_id)
    else
      short_account_url(@account, max_id: max_id, min_id: min_id)
    end
  end

  def media_requested?
    request.path.ends_with?('/media') && !tag_requested?
  end

  def replies_requested?
    request.path.ends_with?('/with_replies') && !tag_requested?
  end

  def tag_requested?
    request.path.split('.').first.ends_with?(Addressable::URI.parse("/tagged/#{params[:tag]}").normalize)
  end

  def filtered_status_page(params)
    if params[:min_id].present?
      filtered_statuses.paginate_by_min_id(PAGE_SIZE, params[:min_id]).reverse
    else
      filtered_statuses.paginate_by_max_id(PAGE_SIZE, params[:max_id], params[:since_id]).to_a
    end
  end

  def restrict_fields_to
    if signed_request_account.present? || public_fetch_mode?
      # Return all fields
    else
      %i(id type preferred_username inbox public_key endpoints)
    end
  end
end
