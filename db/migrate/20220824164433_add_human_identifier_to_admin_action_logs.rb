# frozen_string_literal: true

class AddHumanIdentifierToAdminActionLogs < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table(:admin_action_logs, bulk: true) do |t|
        t.column :human_identifier, :string
        t.column :route_param, :string
        t.column :permalink, :string
      end
    end
  end
end
