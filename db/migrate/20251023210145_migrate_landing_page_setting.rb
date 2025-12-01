# frozen_string_literal: true

class MigrateLandingPageSetting < ActiveRecord::Migration[8.0]
  class Setting < ApplicationRecord; end

  def up
    Setting.reset_column_information

    setting = Setting.find_by(var: 'trends_as_landing_page')
    return unless setting.present? && setting.attributes['value'].present?

    value = YAML.safe_load(setting.attributes['value'], permitted_classes: [ActiveSupport::HashWithIndifferentAccess, Symbol])

    Setting.upsert({
      var: 'landing_page',
      value: value ? "--- trends\n" : "--- about\n",
    },
                   unique_by: index_exists?(:settings, [:thing_type, :thing_id, :var]) ? [:thing_type, :thing_id, :var] : :var)
  end

  def down; end
end
