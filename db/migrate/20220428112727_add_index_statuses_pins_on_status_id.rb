# frozen_string_literal: true

class AddIndexStatusesPinsOnStatusId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :status_pins, [:status_id], name: :index_status_pins_on_status_id, algorithm: :concurrently
  end
end
