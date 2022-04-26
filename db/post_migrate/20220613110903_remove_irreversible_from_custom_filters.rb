# frozen_string_literal: true
require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class RemoveIrreversibleFromCustomFilters < ActiveRecord::Migration[6.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      remove_column :custom_filters, :irreversible
    end
  end

  def down
    safety_assured do
      add_column_with_default :custom_filters, :irreversible, :boolean, allow_null: false, default: false
    end
  end
end
