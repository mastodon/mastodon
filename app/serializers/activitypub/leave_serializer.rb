# frozen_string_literal: true

class ActivityPub::LeaveSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor
  attribute :virtual_object, key: :object

  def id
    ActivityPub::TagManager.instance.uri_for(object) || [ActivityPub::TagManager.instance.uri_for(object.account), '#leave_activities/', object.id].join
  end

  def type
    'Leave'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object.group)
  end
end
