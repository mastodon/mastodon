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
        render json: presenter, serializer: ActivityPub::TagTimelineSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
      end
    end
  end

  private

  def presenter
    ActivityPub::TagTimelinePresenter.new(
      tag: @tag,
      account: current_account,
      local_only: params[:local_only],
      scope: @statuses
    )
  end
end
