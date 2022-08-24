class AddHumanIdentifierToAdminActionLogs < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_action_logs, :human_identifier, :string
    add_column :admin_action_logs, :route_param, :string
    add_column :admin_action_logs, :permalink, :string
  end
end
