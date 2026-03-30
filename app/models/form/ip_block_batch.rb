# frozen_string_literal: true

class Form::IpBlockBatch < Form::BaseBatch
  attr_accessor :ip_block_ids

  def save
    case action
    when 'delete'
      delete!
    end
  end

  private

  def ip_blocks
    @ip_blocks ||= IpBlock.where(id: ip_block_ids)
  end

  def delete!
    verify_authorization(:destroy?)

    ip_blocks.each do |ip_block|
      ip_block.destroy
      log_action :destroy, ip_block
    end
  end

  def verify_authorization(permission)
    ip_blocks.each { |ip_block| authorize(ip_block, permission) }
  end
end
