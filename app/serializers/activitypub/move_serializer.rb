# frozen_string_literal: true

class ActivityPub::MoveSerializer < ActivityPub::Serializer
  attributes :id, :type, :target, :actor
  attribute :virtual_object, key: :object

  def id
    [ActivityPub::TagManager.instance.uri_for(object.account), '#moves/', object.id].join
  end

  def type
    'Move'
  end

  def target
    ActivityPub::TagManager.instance.uri_for(object.target_account)
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end
end
