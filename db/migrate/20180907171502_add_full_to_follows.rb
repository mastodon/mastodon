class AddFullToFollows < ActiveRecord::Migration[5.0]
  def change
    add_column :follows, :full, :boolean
  end
end
