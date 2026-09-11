# frozen_string_literal: true

class Form::EmailDomainBlockBatch < Form::BaseBatch
  attr_accessor :email_domain_block_ids

  def save
    case action
    when 'delete'
      delete!
    end
  end

  private

  def email_domain_blocks
    @email_domain_blocks ||= EmailDomainBlock.where(id: email_domain_block_ids)
  end

  def delete!
    email_domain_blocks.each do |email_domain_block|
      authorize(email_domain_block, :destroy?)
      email_domain_block.destroy!
      log_action :destroy, email_domain_block
    end
  end
end
