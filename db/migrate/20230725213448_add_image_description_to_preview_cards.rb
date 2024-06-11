# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddImageDescriptionToPreviewCards < ActiveRecord::Migration[7.0]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { add_column_with_default :preview_cards, :image_description, :string, default: '', allow_null: false }
  end

  def down
    remove_column :preview_cards, :image_description
  end
end
