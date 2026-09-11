# frozen_string_literal: true

class ActivityPub::ContextsController < ActivityPub::BaseController
  vary_by -> { 'Signature' if authorized_fetch_mode? }

  before_action :require_account_signature!, if: :authorized_fetch_mode?
  before_action :set_conversation
  before_action :set_items

  DESCENDANTS_LIMIT = 60

  def show
    expires_in 3.minutes, public: public_fetch_mode?
    render_with_cache json: context_presenter, serializer: ActivityPub::ContextSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  def items
    expires_in 3.minutes, public: public_fetch_mode?
    render_with_cache json: items_collection_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  private

  def account_required?
    false
  end

  def set_conversation
    account_id, status_id = params[:id].split('-')
    @conversation = Conversation.local.find_by(parent_account_id: account_id, parent_status_id: status_id)
  end

  def set_items
    @items = @conversation.statuses.distributable_visibility.paginate_by_min_id(DESCENDANTS_LIMIT, params[:min_id])
  end

  def context_presenter
    first_page = ActivityPub::CollectionPresenter.new(
      type: :unordered,
      part_of: context_url(@conversation),
      next: next_page,
      items: @items.map { |status| status.local? ? ActivityPub::TagManager.instance.uri_for(status) : status.uri }
    )

    ActivityPub::ContextPresenter.from_conversation(@conversation).tap do |presenter|
      presenter.first = first_page
    end
  end

  def items_collection_presenter
    page = ActivityPub::CollectionPresenter.new(
      id: items_context_url(@conversation, page_params),
      type: :unordered,
      part_of: context_url(@conversation),
      next: next_page,
      items: @items.map { |status| status.local? ? ActivityPub::TagManager.instance.uri_for(status) : status.uri }
    )

    return page if page_requested?

    ActivityPub::CollectionPresenter.new(
      id: items_context_url(@conversation),
      type: :unordered,
      first: page
    )
  end

  def page_requested?
    truthy_param?(:page)
  end

  def next_page
    return nil if @items.size < DESCENDANTS_LIMIT

    items_context_url(@conversation, page: true, min_id: @items.last.id)
  end

  def page_params
    params.permit(:page, :min_id)
  end
end
