# frozen_string_literal: true

class ClearEmailDomainBlocks < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  class EmailDomainBlock < ApplicationRecord
  end

  def up
    EmailDomainBlock.where.not(parent_id: nil).in_batches.delete_all
  end

  def down; end
end
