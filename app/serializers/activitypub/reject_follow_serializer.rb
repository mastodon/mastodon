# frozen_string_literal: true

class ActivityPub::RejectFollowSerializer < ActiveModel::Serializer
  attributes :id, :type, :actor

  attribute :remote_id, key: :object
  delegate :remote_id, to: :object

  def id
    [ActivityPub::TagManager.instance.uri_for(object.target_account), '#rejects/follows/', object.id].join
  end

  def type
    'Reject'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.target_account)
  end
end
