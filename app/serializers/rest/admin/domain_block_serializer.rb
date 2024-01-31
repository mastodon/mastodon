# frozen_string_literal: true

class REST::Admin::DomainBlockSerializer < REST::BaseSerializer
  attributes :id, :domain, :digest, :created_at, :severity,
             :reject_media, :reject_reports,
             :private_comment, :public_comment, :obfuscate

  def id
    object.id.to_s
  end

  def digest
    object.domain_digest
  end
end
