# frozen_string_literal: true

class ActivityPub::GroupOutboxesController < ActivityPub::BaseController
  before_action :set_cache_headers

  def show
    expires_in(3.minutes, public: public_fetch_mode?)
    render json: outbox_presenter, serializer: ActivityPub::OutboxSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  private

  def outbox_presenter
    ActivityPub::CollectionPresenter.new(
      id: outbox_url,
      type: :ordered,
      size: 0,
      items: [],
    )
  end

  def outbox_url
    group_outbox_url(group_id: params[:group_id])
  end
end
