# frozen_string_literal: true

class ActivityPub::RejectFollowSerializer < ActiveModel::Serializer
  attributes :type, :actor

  has_one :object, serializer: ActivityPub::FollowSerializer

  def type
    'Reject'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.target_account)
  end
end
