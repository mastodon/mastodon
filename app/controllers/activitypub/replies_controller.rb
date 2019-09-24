# frozen_string_literal: true

class ActivityPub::RepliesController < ActivityPub::BaseController
  include SignatureAuthentication
  include Authorization
  include AccountOwnedConcern

  DESCENDANTS_LIMIT = 60

  before_action :require_signature!, if: :authorized_fetch_mode?
  before_action :set_status
  before_action :set_cache_headers
  before_action :set_replies

  def index
    expires_in 0, public: public_fetch_mode?
    render json: replies_collection_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json', skip_activities: true
  end

  private

  def set_status
    @status = @account.statuses.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    raise ActiveRecord::RecordNotFound
  end

  def set_replies
    @replies = page_params[:only_other_accounts] ? Status.where.not(account_id: @account.id) : @account.statuses
    @replies = @replies.where(in_reply_to_id: @status.id, visibility: [:public, :unlisted])
    @replies = @replies.paginate_by_min_id(DESCENDANTS_LIMIT, params[:min_id])
  end

  def replies_collection_presenter
    page = ActivityPub::CollectionPresenter.new(
      id: account_status_replies_url(@account, @status, page_params),
      type: :unordered,
      part_of: account_status_replies_url(@account, @status),
      next: next_page,
      items: @replies.map { |status| status.local ? status : status.uri }
    )

    return page if page_requested?

    ActivityPub::CollectionPresenter.new(
      id: account_status_replies_url(@account, @status),
      type: :unordered,
      first: page
    )
  end

  def page_requested?
    params[:page] == 'true'
  end

  def next_page
    only_other_accounts = !(@replies&.last&.account_id == @account.id && @replies.size == DESCENDANTS_LIMIT)
    account_status_replies_url(
      @account,
      @status,
      page: true,
      min_id: only_other_accounts && !page_params[:only_other_accounts] ? nil : @replies&.last&.id,
      only_other_accounts: only_other_accounts
    )
  end

  def page_params
    params_slice(:only_other_accounts, :min_id).merge(page: true)
  end
end
