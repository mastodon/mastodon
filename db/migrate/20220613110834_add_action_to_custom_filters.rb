# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddActionToCustomFilters < ActiveRecord::Migration[6.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :custom_filters, :action, :integer, allow_null: false, default: 0
      execute 'UPDATE custom_filters SET action = 1 WHERE irreversible IS TRUE'
    end
  end

  def down
    execute 'UPDATE custom_filters SET irreversible = (action = 1)'
    remove_column :custom_filters, :action
  end
end
