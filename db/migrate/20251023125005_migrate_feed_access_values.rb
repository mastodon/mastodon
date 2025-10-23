# frozen_string_literal: true

class MigrateFeedAccessValues < ActiveRecord::Migration[8.0]
  class Setting < ApplicationRecord; end

  def up
    %w(local_live_feed_access remote_live_feed_access local_topic_feed_access remote_topic_feed_access).each do |var|
      setting = Setting.find_by(var: var)
      next unless setting.present? && setting.attributes['value'].present?

      value = YAML.safe_load(setting.attributes['value'], permitted_classes: [ActiveSupport::HashWithIndifferentAccess, Symbol])

      case value
      when 'public'
        setting.update(value: "--- all\n")
      when 'authenticated'
        setting.update(value: "--- users\n")
      end
    end
  end

  def down; end
end
