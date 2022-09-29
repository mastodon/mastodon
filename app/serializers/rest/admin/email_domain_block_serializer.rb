# frozen_string_literal: true

class REST::Admin::EmailDomainBlockSerializer < ActiveModel::Serializer
  attributes :id, :domain, :created_at, :history

  def id
    object.id.to_s
  end
end
