# frozen_string_literal: true

class REST::Admin::ExistingDomainBlockErrorSerializer < ActiveModel::Serializer
  attributes :error

  has_one :existing_domain_block, serializer: REST::Admin::DomainBlockSerializer

  def error
    I18n.t('admin.domain_blocks.existing_domain_block', name: existing_domain_block.domain)
  end

  def existing_domain_block
    object
  end
end
