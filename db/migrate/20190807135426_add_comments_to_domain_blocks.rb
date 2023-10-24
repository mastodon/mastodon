# frozen_string_literal: true

class AddCommentsToDomainBlocks < ActiveRecord::Migration[5.2]
  def change
    add_column :domain_blocks, :private_comment, :text
    add_column :domain_blocks, :public_comment, :text
  end
end
