require 'singleton'

class TagManager
  include Singleton
  include RoutingHelper

  def unique_tag(date, id, type)
    "tag:#{Rails.configuration.x.local_domain},#{date.strftime('%Y-%m-%d')}:objectId=#{id}:objectType=#{type}"
  end

  def unique_tag_to_local_id(tag, expected_type)
    matches = Regexp.new("objectId=([\\d]+):objectType=#{expected_type}").match(tag)
    return matches[1] unless matches.nil?
  end

  def local_id?(id)
    id.start_with?("tag:#{Rails.configuration.x.local_domain}")
  end

  def local_domain?(domain)
    domain.nil? || domain.gsub(/[\/]/, '').downcase == Rails.configuration.x.local_domain.downcase
  end

  def uri_for(target)
    return target.uri if target.respond_to?(:local?) && !target.local?

    case target.object_type
    when :person
      account_url(target)
    else
      unique_tag(target.stream_entry.created_at, target.stream_entry.activity_id, target.stream_entry.activity_type)
    end
  end

  def url_for(target)
    return target.url if target.respond_to?(:local?) && !target.local?

    case target.object_type
    when :person
      account_url(target)
    else
      account_stream_entry_url(target.account, target.stream_entry)
    end
  end
end
