require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddEmbedURLToPreviewCards < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :preview_cards, :embed_url, :string, default: '', allow_null: false
    end
  end

  def down
    execute "UPDATE preview_cards SET url=embed_url WHERE embed_url!=''"
    remove_column :preview_cards, :embed_url
  end
end
