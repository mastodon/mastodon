class AddIndexDomainToEmailDomainBlocks < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :email_domain_blocks, :domain, algorithm: :concurrently, unique: true
    change_column_default :email_domain_blocks, :domain, from: nil, to: ''
  end
end
