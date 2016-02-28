module ApplicationHelper
  include RoutingHelper

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

  def subscription_url(account)
    add_base_url_prefix subscriptions_path(id: account.id, format: '')
  end

  def salmon_url(account)
    add_base_url_prefix salmon_path(id: account.id, format: '')
  end

  def profile_url(account)
    account.local? ? super(name: account.username) : account.url
  end

  def status_url(status)
    status.local? ? super(name: status.account.username, id: status.stream_entry.id) : status.url
  end

  def add_base_url_prefix(suffix)
    File.join(root_url, "api", suffix)
  end
end
