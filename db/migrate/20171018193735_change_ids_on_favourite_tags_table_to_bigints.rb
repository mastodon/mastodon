class ChangeIdsOnFavouriteTagsTableToBigints < ActiveRecord::Migration[5.1]
  def up
    safety_assured { 
      change_column :favourite_tags, :tag_id, :bigint
      change_column :favourite_tags, :account_id, :bigint
    }
  end

  def down
    safety_assured { 
      change_column :favourite_tags, :tag_id, :integer
      change_column :favourite_tags, :account_id, :integer
    }
  end
end
