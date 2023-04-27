# frozen_string_literal: true

class REST::DomainBlockSerializer < ActiveModel::Serializer
  attributes :domain, :digest, :severity, :comment

  def domain
    object.public_domain
  end

  def digest
    object.domain_digest
  end

  def comment
    object.public_comment if instance_options[:with_comment]
  end
end
