# frozen_string_literal: true

class TagsController < ApplicationController
  PAGE_SIZE = 20

  layout 'public'

  before_action :set_body_classes
  before_action :set_instance_presenter

  def show
    @tag = Tag.find_normalized!(params[:id])

    respond_to do |format|
      format.html do
        @initial_state_json = ActiveModelSerializers::SerializableResource.new(
          InitialStatePresenter.new(settings: {}, token: current_session&.token),
          serializer: InitialStateSerializer
        ).to_json
      end

      format.rss do
        @statuses = HashtagQueryService.new.call(@tag, params.slice(:any, :all, :none)).limit(PAGE_SIZE)
        @statuses = cache_collection(@statuses, Status)

        render xml: RSS::TagSerializer.render(@tag, @statuses)
      end

      format.json do
        @statuses = HashtagQueryService.new.call(@tag, params.slice(:any, :all, :none), current_account, params[:local]).paginate_by_max_id(PAGE_SIZE, params[:max_id])
        @statuses = cache_collection(@statuses, Status)

        render json: collection_presenter,
               serializer: ActivityPub::CollectionSerializer,
               adapter: ActivityPub::Adapter,
               content_type: 'application/activity+json'
      end
    end
  end

  private

  def set_body_classes
    @body_classes = 'with-modals'
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: tag_url(@tag, params.slice(:any, :all, :none)),
      type: :ordered,
      size: @tag.statuses.count,
      items: @statuses.map { |s| ActivityPub::TagManager.instance.uri_for(s) }
    )
  end
end
