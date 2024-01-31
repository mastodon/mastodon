# frozen_string_literal: true

class REST::Admin::EmailDomainBlockSerializer < REST::BaseSerializer
  attributes :id, :domain, :created_at, :history, :allow_with_approval

  def id
    object.id.to_s
  end
end
