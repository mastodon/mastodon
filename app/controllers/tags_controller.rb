# frozen_string_literal: true

class TagsController < ApplicationController
  include SignatureVerification
  include WebAppControllerConcern

  PAGE_SIZE     = 20
  PAGE_SIZE_MAX = 200

  vary_by -> { public_fetch_mode? ? 'Accept, Accept-Language, Cookie' : 'Accept, Accept-Language, Cookie, Signature' }

  before_action :require_account_signature!, if: -> { request.format == :json && authorized_fetch_mode? }
  before_action :authenticate_user!, if: :limited_federation_mode?
  before_action :set_local
  before_action :set_tag
  before_action :set_statuses, if: -> { request.format == :rss }

  skip_before_action :require_functional!, unless: :limited_federation_mode?

  def show
    respond_to do |format|
      format.html do
        expires_in(15.seconds, public: true, stale_while_revalidate: 30.seconds, stale_if_error: 1.hour) unless user_signed_in?
      end

      format.rss do
        expires_in 0, public: true
      end

      format.json do
        expires_in 3.minutes, public: public_fetch_mode?
        render json: collection_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
      end
    end
  end

  private

  def set_tag
    @tag = Tag.usable.find_normalized!(params[:id])
  end

  def set_local
    @local = truthy_param?(:local)
  end

  def set_statuses
    @statuses = preload_collection(TagFeed.new(@tag, nil, local: @local).get(limit_param), Status)
  end

  def limit_param
    params[:limit].present? ? [params[:limit].to_i, PAGE_SIZE_MAX].min : PAGE_SIZE
  end

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: tag_url(@tag),
      type: :ordered
    )
  end
end
