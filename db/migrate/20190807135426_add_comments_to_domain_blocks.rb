# frozen_string_literal: true

class AddCommentsToDomainBlocks < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table(:domain_blocks, bulk: true) do |t|
        t.column :private_comment, :text
        t.column :public_comment, :text
      end
    end
  end
end
