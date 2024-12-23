# frozen_string_literal: true

class ValidateNotNullToMarkerUserColumn < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM markers
      WHERE user_id IS NULL
    SQL

    validate_check_constraint :markers, name: 'markers_user_id_null'
    change_column_null :markers, :user_id, false
    remove_check_constraint :markers, name: 'markers_user_id_null'
  end

  def down
    add_check_constraint :markers, 'user_id IS NOT NULL', name: 'markers_user_id_null', validate: false
    change_column_null :markers, :user_id, true
  end
end
