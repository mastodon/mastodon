require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddRejectReportsToDomainBlocks < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :domain_blocks, :reject_reports, :boolean, default: false, allow_null: false
    end
  end

  def down
    remove_column :domain_blocks, :reject_reports
  end
end
