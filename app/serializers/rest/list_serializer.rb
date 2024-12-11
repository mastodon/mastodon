# frozen_string_literal: true

class REST::ListSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :title, :description, :type, :replies_policy,
             :exclusive, :created_at, :updated_at

  attribute :slug, if: -> { object.public_list? }
  attribute :url, if: -> { object.public_list? }
  has_one :account, serializer: REST::AccountSerializer, if: -> { object.public_list? }

  def id
    object.id.to_s
  end

  def url
    public_list_url(object.to_url_param)
  end
end
