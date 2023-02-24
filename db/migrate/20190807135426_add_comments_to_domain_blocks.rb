class AddCommentsToDomainBlocks < ActiveRecord::Migration[5.2]
  def change
    change_table :domain_blocks, bulk: true do |t|
      t.column :private_comment, :text
      t.column :public_comment, :text
    end
  end
end
