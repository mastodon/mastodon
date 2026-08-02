# frozen_string_literal: true

class AddEndOfSupportToSoftwareUpdates < ActiveRecord::Migration[8.1]
  def change
    add_column :software_updates, :end_of_support, :date
  end
end
