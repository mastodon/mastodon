class AddFullAccessToFollows < ActiveRecord::Migration[5.0]
  def up
    add_column :follows, :full_access, :boolean
    change_column_null :follows, :full_access, true
    change_column_default :follows, :full_access, true
  end
  
  def down
    remove_column :follows, :full_access
  end

end
