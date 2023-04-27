# frozen_string_literal: true

class REST::Admin::CanonicalEmailBlockSerializer < ActiveModel::Serializer
  attributes :id, :canonical_email_hash

  def id
    object.id.to_s
  end
end
