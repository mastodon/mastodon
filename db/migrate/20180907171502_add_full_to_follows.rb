class AddFullToFollows < ActiveRecord::Migration[5.0]
  def up
    add_column :follows, :full, :boolean
    change_column_null :follows, :full, true
    change_column_default :follows, :full, true
  end
  
  def down
    remove_column :follows, :full
  end

end
