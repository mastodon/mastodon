# frozen_string_literal: true

class DomainBlockValidator < ActiveModel::Validator
  def validate(block)
    return unless block.noop? && !block.reject_media?
    block.errors.add(:severity, I18n.t('admin.domain_blocks.new.severity.invalid'))
  end
end
