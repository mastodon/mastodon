class AddIpsToEmailDomainBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :email_domain_blocks, :ips, :inet, array: true
    add_column :email_domain_blocks, :last_refresh_at, :datetime
  end
end
