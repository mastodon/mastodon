# frozen_string_literal: true

class AddLocalToStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :statuses, :local, :boolean, null: true, default: nil # rubocop:disable Rails/ThreeStateBooleanColumn
  end
end
