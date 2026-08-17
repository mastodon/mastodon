# frozen_string_literal: true

class ActivityPub::FlagSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :content
  attribute :virtual_object, key: :object

  def id
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def type
    'Flag'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(instance_options[:account] || object.account)
  end

  def virtual_object
    target_account_uris + status_uris + collection_uris
  end

  def content
    object.comment
  end

  private

  def target_account_uris
    [ActivityPub::TagManager.instance.uri_for(object.target_account)]
  end

  def status_uris
    object.statuses.map { |s| ActivityPub::TagManager.instance.uri_for(s) }
  end

  def collection_uris
    object.collections.map { |c| ActivityPub::TagManager.instance.uri_for(c) }
  end
end
