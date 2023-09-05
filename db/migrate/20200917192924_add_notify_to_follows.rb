# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddNotifyToFollows < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :follows, :notify, :boolean, default: false, allow_null: false
      add_column_with_default :follow_requests, :notify, :boolean, default: false, allow_null: false
    end
  end

  def down
    remove_column :follows, :notify
    remove_column :follow_requests, :notify
  end
end
