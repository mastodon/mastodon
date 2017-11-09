class AddFederateFlag < ActiveRecord::Migration[5.1]
  def change
    add_column :statuses, :federate, :boolean, null: true
  end
end
