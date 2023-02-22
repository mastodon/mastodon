# frozen_string_literal: true

class RemoveDevices < ActiveRecord::Migration[5.0]
  def change
    drop_table :devices if table_exists?(:devices)
  end
end
