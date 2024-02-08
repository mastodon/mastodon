# frozen_string_literal: true

class AddAllowWithApprovalToEmailDomainBlocks < ActiveRecord::Migration[7.1]
  def change
    add_column :email_domain_blocks, :allow_with_approval, :boolean, default: false, null: false
  end
end
