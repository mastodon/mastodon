class AddStealthToBlocks < ActiveRecord::Migration[5.2]
  def change
    add_column :blocks, :stealth, :boolean
  end
end

