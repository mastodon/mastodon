# frozen_string_literal: true

class Form::IpBlockBatch
  include ActiveModel::Model
  include Authorization
  include AccountableConcern

  attr_accessor :ip_block_ids, :action, :current_account

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
    ip_blocks.each do |ip_block|
      authorize(ip_block, :destroy?)
      ip_block.destroy
      log_action :destroy, ip_block
    end
  end
end
