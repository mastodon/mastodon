# frozen_string_literal: true

class ActivityPub::OutboxesController < ActivityPub::BaseController
  LIMIT = 20

  include SignatureVerification
  include AccountOwnedConcern

  before_action :require_signature!, if: :authorized_fetch_mode?
  before_action :set_statuses
  before_action :set_cache_headers

  def show
    expires_in(page_requested? ? 0 : 3.minutes, public: public_fetch_mode? && !(signed_request_account.present? && page_requested?))
    render json: outbox_presenter, serializer: ActivityPub::OutboxSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  private

  def outbox_presenter
    if page_requested?
      ActivityPub::CollectionPresenter.new(
        id: account_outbox_url(@account, page_params),
        type: :ordered,
        part_of: account_outbox_url(@account),
        prev: prev_page,
        next: next_page,
        items: @statuses
      )
    else
      ActivityPub::CollectionPresenter.new(
        id: account_outbox_url(@account),
        type: :ordered,
        size: @account.statuses_count,
        first: account_outbox_url(@account, page: true),
        last: account_outbox_url(@account, page: true, min_id: 0)
      )
    end
  end

  def next_page
    account_outbox_url(@account, page: true, max_id: @statuses.last.id) if @statuses.size == LIMIT
  end

  def prev_page
    account_outbox_url(@account, page: true, min_id: @statuses.first.id) unless @statuses.empty?
  end

  def set_statuses
    return unless page_requested?

    @statuses = @account.statuses.permitted_for(@account, signed_request_account)
    @statuses = @statuses.paginate_by_id(LIMIT, params_slice(:max_id, :min_id, :since_id))
    @statuses = cache_collection(@statuses, Status)
  end

  def page_requested?
    truthy_param?(:page)
  end

  def page_params
    { page: true, max_id: params[:max_id], min_id: params[:min_id] }.compact
  end
end
