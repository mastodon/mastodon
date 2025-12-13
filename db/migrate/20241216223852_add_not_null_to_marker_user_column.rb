# frozen_string_literal: true

class AddNotNullToMarkerUserColumn < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :markers, 'user_id IS NOT NULL', name: 'markers_user_id_null', validate: false
  end
end
