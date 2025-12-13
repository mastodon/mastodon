# frozen_string_literal: true

class OStatus::TagManager
  include Singleton
  include RoutingHelper

  def unique_tag(date, id, type)
    "tag:#{Rails.configuration.x.local_domain},#{date.strftime('%Y-%m-%d')}:objectId=#{id}:objectType=#{type}"
  end

  def unique_tag_to_local_id(tag, expected_type)
    return nil unless local_id?(tag)

    if ActivityPub::TagManager.instance.local_uri?(tag)
      ActivityPub::TagManager.instance.uri_to_local_id(tag)
    else
      matches = Regexp.new("objectId=([\\d]+):objectType=#{expected_type}").match(tag)
      matches[1] unless matches.nil?
    end
  end

  def local_id?(id)
    id.start_with?("tag:#{Rails.configuration.x.local_domain}") || ActivityPub::TagManager.instance.local_uri?(id)
  end

  def uri_for(target)
    return target.uri if target.respond_to?(:local?) && !target.local?

    case target.object_type
    when :person
      account_url(target)
    when :note, :comment, :activity
      target.uri || unique_tag(target.created_at, target.id, 'Status')
    end
  end
end
