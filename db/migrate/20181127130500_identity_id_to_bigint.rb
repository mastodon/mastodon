# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class IdentityIdToBigint < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      change_column_type_concurrently :identities, :id, :bigint
      cleanup_concurrent_column_type_change :identities, :id

      change_column_type_concurrently :identities, :user_id, :bigint
      cleanup_concurrent_column_type_change :identities, :user_id
    end
  end

  def down
    safety_assured do
      change_column_type_concurrently :identities, :id, :integer
      cleanup_concurrent_column_type_change :identities, :id

      change_column_type_concurrently :identities, :user_id, :integer
      cleanup_concurrent_column_type_change :identities, :user_id
    end
  end
end
