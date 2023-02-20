# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class RemoveWholeWordFromCustomFilters < ActiveRecord::Migration[6.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      remove_column :custom_filters, :whole_word
    end
  end

  def down
    safety_assured do
      add_column_with_default :custom_filters, :whole_word, :boolean, default: true, allow_null: false
    end
  end
end
