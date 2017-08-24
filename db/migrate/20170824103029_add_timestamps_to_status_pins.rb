class AddTimestampsToStatusPins < ActiveRecord::Migration[5.1]
  def change
    add_timestamps :status_pins, null: true
  end
end
