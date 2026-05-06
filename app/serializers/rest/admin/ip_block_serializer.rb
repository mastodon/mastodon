# frozen_string_literal: true

class REST::Admin::IpBlockSerializer < ActiveModel::Serializer
  attributes :id, :ip, :severity, :comment,
             :created_at, :expires_at

  def id
    object.id.to_s
  end

  def ip
    object.to_cidr
  end
end
