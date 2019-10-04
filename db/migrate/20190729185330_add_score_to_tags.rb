class AddScoreToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :score, :int
  end
end
