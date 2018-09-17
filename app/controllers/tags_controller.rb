# frozen_string_literal: true

class TagsController < ApplicationController
  PAGE_SIZE = 20

  before_action :set_body_classes
  before_action :set_instance_presenter

  def intersection
    @tags = Tag.where(name: Array(params[:tags]).map(&:downcase))
    @tags = Tag.none if params[:tags].length > @tags.length # return empty set if not all tags exist
    method = if params[:or_filter] then :as_tag_timeline else :as_tag_intersection

    respond_to do |format|
      format.html do
        serializable_resource = ActiveModelSerializers::SerializableResource.new(InitialStatePresenter.new(initial_state_params), serializer: InitialStateSerializer)
        @initial_state_json   = serializable_resource.to_json
      end
      format.rss do
        @statuses = Status.send(method, @tags).limit(PAGE_SIZE)
        @statuses = cache_collection(@statuses, Status)

        render xml: RSS::MultiTagSerializer.render(@tags.first, @statuses) # TODO: handle this better
      end
      format.json do
        @statuses = Status.send(method, @tags, current_account, params[:locale])

        render json: collection_presenter,
               serializer: ActivityPub::CollectionSerializer,
               adapter: ActivityPub::Adapter,
               content_type: 'application/activity+json'
      end
    end
  end

  def show
    @tag = Tag.find_by!(name: params[:id].downcase)

    respond_to do |format|
      format.html do
        serializable_resource = ActiveModelSerializers::SerializableResource.new(InitialStatePresenter.new(initial_state_params), serializer: InitialStateSerializer)
        @initial_state_json   = serializable_resource.to_json
      end

      format.rss do
        @statuses = Status.as_tag_timeline(@tag).limit(PAGE_SIZE)
        @statuses = cache_collection(@statuses, Status)

        render xml: RSS::TagSerializer.render(@tag, @statuses)
      end

      format.json do
        @statuses = Status.as_tag_timeline(@tag, current_account, params[:local]).paginate_by_max_id(PAGE_SIZE, params[:max_id])
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
      id: @tag ? tag_url(@tag) : nil, # TODO: deal with url
      type: :ordered,
      size: @tag ? @tag.statuses.count : @statuses.length, # TODO: deal with size for intersection / collection
      items: @statuses.map { |s| ActivityPub::TagManager.instance.uri_for(s) }
    )
  end

  def initial_state_params
    {
      settings: {},
      token: current_session&.token,
    }
  end
end
