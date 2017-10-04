# frozen_string_literal: true

class TagsController < ApplicationController
  layout 'public'

  def show
    @tag      = Tag.find_by!(name: params[:id].downcase)
    @statuses = Timeline.tag(
      @tag,
      account: current_account,
      local_only: params[:local],
      limit: 20,
      max_id: params[:max_id]
    )
    @statuses = cache_collection(@statuses, Status)

    respond_to do |format|
      format.html

      format.json do
        render json: collection_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
      end
    end
  end

  private

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: tag_url(@tag),
      type: :ordered,
      size: @tag.statuses.count,
      items: @statuses.map { |s| ActivityPub::TagManager.instance.uri_for(s) }
    )
  end
end
