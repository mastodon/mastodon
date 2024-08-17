# frozen_string_literal: true

class SplitPublicTimelinesSetting < ActiveRecord::Migration[7.1]
  def up
    previous_setting = Setting.find_by(var: 'timeline_preview')

    unless previous_setting.nil?
      Setting['timeline_preview_local'] = previous_setting.value
      Setting['timeline_preview_remote'] = previous_setting.value
      previous_setting.delete
    end
  end

  def down
    preview_local = Setting['timeline_preview_local']
    preview_remote = Setting['timeline_preview_remote']

    unless preview_local.nil? && preview_remote.nil?
      preview_timelines = (!preview_local.nil? && preview_local) && (!preview_remote.nil? && preview_remote)
      Setting['timeline_preview'] = preview_timelines
    end

    Setting.where(var: ['timeline_preview_local', 'timeline_preview_remote']).delete_all
  end
end
