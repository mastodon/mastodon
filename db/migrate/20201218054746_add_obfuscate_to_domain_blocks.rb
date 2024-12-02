# frozen_string_literal: true

class AddObfuscateToDomainBlocks < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured { add_column :domain_blocks, :obfuscate, :boolean, default: false, null: false }
  end

  def down
    remove_column :domain_blocks, :obfuscate
  end
end
