require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddColumnMentionsDirect < ActiveRecord::Migration[5.0]

  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up

    safety_assured do
      add_column_with_default :mentions, :direct, :boolean, default: false, allow_null: false
    end

    Status.unscoped.select('id').where(Status.arel_table[:visibility].eq(3)).find_in_batches do |batch|
      Mention.where(status_id: batch.map(&:id)).update_all('direct=TRUE')
    end

    add_index :mentions, [:account_id, :status_id], where: 'direct', algorithm: :concurrently, name: 'index_mentions_direct'
  end

  def down
    remove_index :mentions, name: 'index_mentions_direct'
    remove_column :mentions, :direct, :boolean
  end
end
