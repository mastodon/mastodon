# frozen_string_literal: true

class ActivityPub::TagTimelinePresenter < ActiveModelSerializers::Model
  attributes :tag, :account, :local_only, :scope
end
