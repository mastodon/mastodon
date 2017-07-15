# frozen_string_literal: true

class ActivityPub::CollectionPresenter < ActiveModelSerializers::Model
  attributes :id, :type, :size, :items
end
