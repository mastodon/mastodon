# frozen_string_literal: true

class REST::TagSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :name, :url, :history

  attribute :following, if: :current_user?
  attribute :featuring, if: :current_user?

  def id
    object.id.to_s
  end

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
      TagFollow.exists?(tag_id: object.id, account_id: current_user.account_id)
    end
  end

  def featuring
    if instance_options && instance_options[:relationships]
      instance_options[:relationships].featuring_map[object.id] || false
    else
      FeaturedTag.exists?(tag_id: object.id, account_id: current_user.account_id)
    end
  end

  def current_user?
    !current_user.nil?
  end
end
