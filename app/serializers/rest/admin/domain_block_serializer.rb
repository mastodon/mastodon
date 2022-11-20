# frozen_string_literal: true

class REST::Admin::DomainBlockSerializer < ActiveModel::Serializer
  attributes :id, :domain, :created_at, :severity,
             :reject_media, :reject_reports, :reject_follows,
             :private_comment, :public_comment, :obfuscate

  def id
    object.id.to_s
  end
end
