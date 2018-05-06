# frozen_string_literal: true

class ActivityPub::CollectionPresenter < ActiveModelSerializers::Model
  attributes :id, :type, :size, :items, :part_of, :first, :last, :next, :prev
end
