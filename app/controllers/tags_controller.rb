# frozen_string_literal: true

class TagsController < ApplicationController
  layout 'public'

  def show
    @tag      = Tag.find_by!(name: params[:id].downcase)
    @statuses = Status.as_tag_timeline(@tag, current_account, params[:local]).paginate_by_max_id(20, params[:max_id])
    @statuses = cache_collection(@statuses, Status)

    respond_to do |format|
      format.html

      format.json do
        render json: collection_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter
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
