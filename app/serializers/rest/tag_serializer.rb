# frozen_string_literal: true

class REST::TagSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :name, :url, :history

  attribute :following, if: :current_user?

  def url
    tag_url(object)
  end

  def name
    object.display_name
  end

  def following
    if instance_options && instance_options[:relationships]
      instance_options[:relationships].following_map[object.id] || false
    else
      TagFollow.where(tag_id: object.id, account_id: current_user.account_id).exists?
    end
  end

  def current_user?
    !current_user.nil?
  end
end
