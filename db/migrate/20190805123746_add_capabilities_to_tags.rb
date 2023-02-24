class AddCapabilitiesToTags < ActiveRecord::Migration[5.2]
  def change
    change_table :tags, bulk: true do |t|
      t.column :usable, :boolean
      t.column :trendable, :boolean
      t.column :listable, :boolean
      t.column :reviewed_at, :datetime
      t.column :requested_review_at, :datetime
    end
  end
end
