class REST::ProfileEmojiSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :shortcode, :account_id, :url, :account_url

  def shortcode
    object.username
  end

  def account_id
    object.id
  end

  def url
    full_asset_url(object.avatar_static_url)
  end

  def account_url
    short_account_url(object)
  end
end
