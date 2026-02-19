# frozen_string_literal: true

class Form::UsernameBlockBatch < Form::BaseBatch
  attr_accessor :username_block_ids

  def save
    case action
    when 'delete'
      delete!
    end
  end

  private

  def username_blocks
    @username_blocks ||= UsernameBlock.where(id: username_block_ids)
  end

  def delete!
    verify_authorization(:destroy?)

    username_blocks.each do |username_block|
      username_block.destroy
      log_action :destroy, username_block
    end
  end

  def verify_authorization(permission)
    username_blocks.each { |username_block| authorize(username_block, permission) }
  end
end
