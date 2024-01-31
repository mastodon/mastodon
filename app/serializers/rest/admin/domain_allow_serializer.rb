# frozen_string_literal: true

class REST::Admin::DomainAllowSerializer < REST::BaseSerializer
  attributes :id, :domain, :created_at

  def id
    object.id.to_s
  end
end
