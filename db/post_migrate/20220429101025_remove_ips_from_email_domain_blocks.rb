# frozen_string_literal: true

class RemoveIpsFromEmailDomainBlocks < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      remove_column :email_domain_blocks, :ips, :inet, array: true
      remove_column :email_domain_blocks, :last_refresh_at, :datetime
    end
  end
end
