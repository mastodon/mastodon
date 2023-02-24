class AddHumanIdentifierToAdminActionLogs < ActiveRecord::Migration[6.1]
  def change
    change_table :admin_action_logs, bulk: true do |t|
      t.column :human_identifier, :string
      t.column :route_param, :string
      t.column :permalink, :string
    end
  end
end
