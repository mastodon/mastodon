# frozen_string_literal: true

class AddListToCircles < ActiveRecord::Migration[7.0]
  def change
    add_column :circles, :list_id, :bigint
  end
end
