# frozen_string_literal: true

class AddDetailedForwardingToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :forwarded_at, :timestamp, null: true
    add_column :reports, :forwarded_to_domains, :string, default: [], null: false, array: true

    safety_assured { add_reference :reports, :forwarded_by, null: true, foreign_key: { to_table: 'accounts', on_delete: :nullify }, index: false }
  end
end
