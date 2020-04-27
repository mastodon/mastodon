# frozen_string_literal: true

class ActivityPub::CollectionPresenter < ActiveModelSerializers::Model
  attributes :id, :type, :size, :items, :page, :part_of, :first, :last, :next, :prev
end
