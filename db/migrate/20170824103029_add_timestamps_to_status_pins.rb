# frozen_string_literal: true

class AddTimestampsToStatusPins < ActiveRecord::Migration[5.1]
  def change
    add_timestamps :status_pins, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
