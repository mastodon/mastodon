# frozen_string_literal: true

class AddIpsToEmailDomainBlocks < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table(:email_domain_blocks, bulk: true) do |t|
        t.column :ips, :inet, array: true
        t.column :last_refresh_at, :datetime
      end
    end
  end
end
