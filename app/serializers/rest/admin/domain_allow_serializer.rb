# frozen_string_literal: true

class REST::Admin::DomainAllowSerializer < ActiveModel::Serializer
  attributes :id, :domain, :created_at

  def id
    object.id.to_s
  end
end
