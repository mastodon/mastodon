# frozen_string_literal: true

class ActivityPub::ActivityPresenter < ActiveModelSerializers::Model
  attributes :id, :actor, :object
end
