# frozen_string_literal: true

class InstanceActorsController < ApplicationController
  layout 'public'

  before_action :set_cache_headers

  def show
    respond_to do |format|
      format.html do
        mark_cacheable!

        @instance_presenter = InstancePresenter.new
      end

      format.json do
        mark_cacheable!

        render_cached_json(['activitypub', 'instance-actor'], content_type: 'application/activity+json') do
          ActiveModelSerializers::SerializableResource.new(InstanceActorPresenter.new, serializer: ActivityPub::InstanceActorSerializer, adapter: ActivityPub::Adapter)
        end
      end
    end
  end
end
