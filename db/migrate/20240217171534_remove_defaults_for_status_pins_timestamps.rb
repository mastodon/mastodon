# frozen_string_literal: true

class RemoveDefaultsForStatusPinsTimestamps < ActiveRecord::Migration[7.1]
  def change
    change_column_default :status_pins, :created_at, from: -> { 'CURRENT_TIMESTAMP' }, to: nil
    change_column_default :status_pins, :updated_at, from: -> { 'CURRENT_TIMESTAMP' }, to: nil
  end
end
