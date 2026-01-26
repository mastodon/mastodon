# frozen_string_literal: true

class MigrateDefaultThemeSetting < ActiveRecord::Migration[8.0]
  class Setting < ApplicationRecord; end

  def up
    Setting.reset_column_information

    setting = Setting.find_by(var: 'theme')
    return unless setting.present? && setting.attributes['value'].present? && %w(mastodon-light contrast system).include?(setting.attributes['value'])

    Setting.upsert(
      {
        var: 'theme',
        value: "--- default\n",
      },
      unique_by: index_exists?(:settings, [:thing_type, :thing_id, :var]) ? [:thing_type, :thing_id, :var] : :var
    )
  end

  def down; end
end
