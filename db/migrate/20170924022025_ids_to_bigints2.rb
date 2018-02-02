class IdsToBigints2 < ActiveRecord::Migration[5.1]
  def up
    change_column :statuses_tags, :tag_id, :bigint
  end

  def down
    change_column :statuses_tags, :tag_id, :integer
  end
end
