# frozen_string_literal: true

class ActivityPub::FlagSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :content, :summary
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
    [ActivityPub::TagManager.instance.uri_for(object.target_account)] + object.statuses.map { |s| ActivityPub::TagManager.instance.uri_for(s) }
  end

  def summary
    object.category
  end

  def content
    if object.violation?
      "Comment:\n#{object.comment}\n\nViolated #{Rails.configuration.x.local_domain}'s Rules: \n- #{object.rules.map(&:text).join("\n -")}"
    else
      object.comment
    end
  end
end
