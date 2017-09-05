class UpdateLocalStatuses < ActiveRecord::Migration[5.1]
  def up
    execute "UPDATE statuses SET local = 't' WHERE uri IS NULL;"
  end

  def down; end
end
