# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddObfuscateToDomainBlocks < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { add_column_with_default :domain_blocks, :obfuscate, :boolean, default: false, allow_null: false }
  end

  def down
    remove_column :domain_blocks, :obfuscate
  end
end
