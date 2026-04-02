# frozen_string_literal: true

class MigrateTimelinePreviewSetting < ActiveRecord::Migration[8.0]
  class Setting < ApplicationRecord; end

  def up
    Setting.reset_column_information

    setting = Setting.find_by(var: 'timeline_preview')
    return unless setting.present? && setting.attributes['value'].present?

    value = YAML.safe_load(setting.attributes['value'], permitted_classes: [ActiveSupport::HashWithIndifferentAccess, Symbol])

    Setting.upsert_all(
      %w(local_live_feed_access remote_live_feed_access local_topic_feed_access remote_topic_feed_access).map do |var|
        { var: var, value: value ? "--- public\n" : "--- authenticated\n" }
      end,
      unique_by: index_exists?(:settings, [:thing_type, :thing_id, :var]) ? [:thing_type, :thing_id, :var] : :var
    )
  end

  def down; end
end
