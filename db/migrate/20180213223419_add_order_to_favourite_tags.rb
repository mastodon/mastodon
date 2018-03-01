require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddOrderToFavouriteTags < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :favourite_tags, :order, :integer, default: 0, allow_null: false
    end
  end

  def down
    remove_column :favourite_tags, :order
  end
end

# execute update
# update favourite_tags set order = temp.rnum from (select f.id, f.account_id, row_number() OVER (PARTITION BY f.account_id ORDER BY f.id) AS rnum from favourite_tags as f group by f.account_id, f.id order by f.id) as temp where favourite_tags.id = temp.id
