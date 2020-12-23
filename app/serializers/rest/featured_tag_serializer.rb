# frozen_string_literal: true

class REST::FeaturedTagSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :statuses_count, :last_status_at

  def id
    object.id.to_s
  end
  
  def url
    short_account_tag_url(object.account, object.tag)
  end
end
