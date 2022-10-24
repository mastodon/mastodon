# frozen_string_literal: true

class ActivityPub::RejectCreatePresenter < ActiveModelSerializers::Model
  attributes :actor, :create_uri, :create_actor, :create_object_uri
end
