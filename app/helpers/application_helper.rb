module ApplicationHelper
  include RoutingHelper

  def unique_tag(date, id, type)
    "tag:#{LOCAL_DOMAIN},#{date.strftime('%Y-%m-%d')}:objectId=#{id}:objectType=#{type}"
  end

  def subscription_url(account)
    add_base_url_prefix subscriptions_path(id: account.id, format: '')
  end

  def salmon_url(account)
    add_base_url_prefix salmon_path(id: account.id, format: '')
  end

  def add_base_url_prefix(suffix)
    File.join(root_url, "api", suffix)
  end
end
