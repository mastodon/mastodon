class AddStoryToCthulhu < ActiveRecord::Migration[5.2]
  def change
    add_column :cthulhus, :story, :text
  end
end
