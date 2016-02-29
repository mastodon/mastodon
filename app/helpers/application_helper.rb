module ApplicationHelper
  def unique_tag(date, id, type)
    "tag:#{LOCAL_DOMAIN},#{date.strftime('%Y-%m-%d')}:objectId=#{id}:objectType=#{type}"
  end

  def unique_tag_to_local_id(tag, expected_type)
    matches = Regexp.new("objectId=([\\d]+):objectType=#{expected_type}").match(tag)
    return matches[1] unless matches.nil?
  end

  def local_id?(id)
    id.start_with?("tag:#{LOCAL_DOMAIN}")
  end
end
