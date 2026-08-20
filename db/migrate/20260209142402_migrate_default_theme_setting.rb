# frozen_string_literal: true

class MigrateDefaultThemeSetting < ActiveRecord::Migration[8.0]
  class Setting < ApplicationRecord; end

  def up
    Setting.reset_column_information

    setting = Setting.find_by(var: 'theme')
    return unless setting.present? && setting.attributes['value'].present?

    theme = YAML.safe_load(setting.attributes['value'], permitted_classes: [ActiveSupport::HashWithIndifferentAccess, Symbol])
    return unless %w(mastodon-light contrast system).include?(theme)

    setting.update_column('value', "--- default\n")
  end

  def down; end
end
