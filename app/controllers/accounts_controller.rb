# frozen_string_literal: true

class AccountsController < ApplicationController
  PAGE_SIZE = 20

  include AccountControllerConcern

  before_action :set_cache_headers

  def show
    respond_to do |format|
      format.html do
        @body_classes      = 'with-modals'
        @pinned_statuses   = []
        @endorsed_accounts = @account.endorsed_accounts.to_a.sample(4)

        if current_account && @account.blocking?(current_account)
          @statuses = []
          return
        end

        @pinned_statuses = cache_collection(@account.pinned_statuses, Status) if show_pinned_statuses?
        @statuses        = filtered_status_page(params)
        @statuses        = cache_collection(@statuses, Status)

        unless @statuses.empty?
          @older_url = older_url if @statuses.last.id > filtered_statuses.last.id
          @newer_url = newer_url if @statuses.first.id < filtered_statuses.first.id
        end
      end

      format.atom do
        @entries = @account.stream_entries.where(hidden: false).with_includes.paginate_by_max_id(PAGE_SIZE, params[:max_id], params[:since_id])
        render xml: OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.feed(@account, @entries.reject { |entry| entry.status.nil? }))
      end

      format.rss do
        @statuses = cache_collection(default_statuses.without_reblogs.without_replies.limit(PAGE_SIZE), Status)
        render xml: RSS::AccountSerializer.render(@account, @statuses)
      end

      format.json do
        skip_session!

        render_cached_json(['activitypub', 'actor', @account], content_type: 'application/activity+json') do
          ActiveModelSerializers::SerializableResource.new(@account, serializer: ActivityPub::ActorSerializer, adapter: ActivityPub::Adapter)
        end
      end
    end
  end

  private

  def show_pinned_statuses?
    [replies_requested?, media_requested?, params[:max_id].present?, params[:min_id].present?].none?
  end

  def filtered_statuses
    default_statuses.tap do |statuses|
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

  def set_account
    @account = Account.find_local!(params[:username])
  end

  def older_url
    ::Rails.logger.info("older: max_id #{@statuses.last.id}, url #{pagination_url(max_id: @statuses.last.id)}")
    pagination_url(max_id: @statuses.last.id)
  end

  def newer_url
    pagination_url(min_id: @statuses.first.id)
  end

  def pagination_url(max_id: nil, min_id: nil)
    if media_requested?
      short_account_media_url(@account, max_id: max_id, min_id: min_id)
    elsif replies_requested?
      short_account_with_replies_url(@account, max_id: max_id, min_id: min_id)
    else
      short_account_url(@account, max_id: max_id, min_id: min_id)
    end
  end

  def media_requested?
    request.path.ends_with?('/media')
  end

  def replies_requested?
    request.path.ends_with?('/with_replies')
  end

  def filtered_status_page(params)
    if params[:min_id].present?
      filtered_statuses.paginate_by_min_id(PAGE_SIZE, params[:min_id]).reverse
    else
      filtered_statuses.paginate_by_max_id(PAGE_SIZE, params[:max_id], params[:since_id]).to_a
    end
  end
end
