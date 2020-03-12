class AddParentIdToEmailDomainBlocks < ActiveRecord::Migration[5.2]
  def change
    add_reference :email_domain_blocks, :parent, null: true, default: nil, foreign_key: { on_delete: :cascade, to_table: :email_domain_blocks }, index: false
  end
end
