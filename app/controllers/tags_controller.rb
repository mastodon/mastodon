# frozen_string_literal: true

class TagsController < ApplicationController
  include SignatureVerification

  PAGE_SIZE = 20

  layout 'public'

  before_action :require_signature!, if: -> { request.format == :json && authorized_fetch_mode? }
  before_action :authenticate_user!, if: :whitelist_mode?
  before_action :set_tag
  before_action :set_body_classes
  before_action :set_instance_presenter

  def show
    respond_to do |format|
      format.html do
        expires_in 0, public: true
      end

      format.rss do
        expires_in 0, public: true

        @statuses = HashtagQueryService.new.call(@tag, params.slice(:any, :all, :none)).limit(PAGE_SIZE)
        @statuses = cache_collection(@statuses, Status)

        render xml: RSS::TagSerializer.render(@tag, @statuses)
      end

      format.json do
        expires_in 3.minutes, public: public_fetch_mode?

        @statuses = HashtagQueryService.new.call(@tag, params.slice(:any, :all, :none), current_account, params[:local]).paginate_by_max_id(PAGE_SIZE, params[:max_id])
        @statuses = cache_collection(@statuses, Status)

        render json: collection_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
      end
    end
  end

  private

  def set_tag
    @tag = Tag.usable.find_normalized!(params[:id])
  end

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
