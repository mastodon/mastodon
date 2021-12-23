# frozen_string_literal: true

class UserSettingsDecorator
  attr_reader :user, :settings

  def initialize(user)
    @user = user
  end

  def update(settings)
    @settings = settings
    process_update
  end

  private

  def process_update
    update_if_changed('notification_emails', merged_notification_emails, 'notification_emails')
    update_if_changed('interactions', merged_interactions, 'interactions')
    update_if_changed('default_privacy', default_privacy_preference, 'setting_default_privacy')
    update_if_changed('default_sensitive', default_sensitive_preference, 'setting_default_sensitive')
    update_if_changed('default_language', default_language_preference, 'setting_default_language')
    update_if_changed('unfollow_modal', unfollow_modal_preference, 'setting_unfollow_modal')
    update_if_changed('boost_modal', boost_modal_preference, 'setting_boost_modal')
    update_if_changed('delete_modal', delete_modal_preference, 'setting_delete_modal')
    update_if_changed('auto_play_gif', auto_play_gif_preference, 'setting_auto_play_gif')
    update_if_changed('display_media', display_media_preference, 'setting_display_media')
    update_if_changed('expand_spoilers', expand_spoilers_preference, 'setting_expand_spoilers')
    update_if_changed('reduce_motion', reduce_motion_preference, 'setting_reduce_motion')
    update_if_changed('disable_swiping', disable_swiping_preference, 'setting_disable_swiping')
    update_if_changed('system_font_ui', system_font_ui_preference, 'setting_system_font_ui')
    update_if_changed('noindex', noindex_preference, 'setting_noindex')
    update_if_changed('theme', theme_preference, 'setting_theme')
    update_if_changed('aggregate_reblogs', aggregate_reblogs_preference, 'setting_aggregate_reblogs')
    update_if_changed('show_application', show_application_preference, 'setting_show_application')
    update_if_changed('advanced_layout', advanced_layout_preference, 'setting_advanced_layout')
    update_if_changed('use_blurhash', use_blurhash_preference, 'setting_use_blurhash')
    update_if_changed('use_pending_items', use_pending_items_preference, 'setting_use_pending_items')
    update_if_changed('trends', trends_preference, 'setting_trends')
    update_if_changed('crop_images', crop_images_preference, 'setting_crop_images')
    update_if_changed('always_send_emails', always_send_emails_preference, 'setting_always_send_emails')
    update_if_changed('notification_sound', notification_sound_preference, 'setting_notification_sound')
  end

  def merged_notification_emails
    user.settings['notification_emails'].merge coerced_settings('notification_emails').to_h
  end

  def merged_interactions
    user.settings['interactions'].merge coerced_settings('interactions').to_h
  end

  def default_privacy_preference
    settings['setting_default_privacy']
  end

  def default_sensitive_preference
    boolean_cast_setting 'setting_default_sensitive'
  end

  def unfollow_modal_preference
    boolean_cast_setting 'setting_unfollow_modal'
  end

  def boost_modal_preference
    boolean_cast_setting 'setting_boost_modal'
  end

  def delete_modal_preference
    boolean_cast_setting 'setting_delete_modal'
  end

  def system_font_ui_preference
    boolean_cast_setting 'setting_system_font_ui'
  end

  def auto_play_gif_preference
    boolean_cast_setting 'setting_auto_play_gif'
  end

  def display_media_preference
    settings['setting_display_media']
  end

  def expand_spoilers_preference
    boolean_cast_setting 'setting_expand_spoilers'
  end

  def reduce_motion_preference
    boolean_cast_setting 'setting_reduce_motion'
  end

  def disable_swiping_preference
    boolean_cast_setting 'setting_disable_swiping'
  end

  def noindex_preference
    boolean_cast_setting 'setting_noindex'
  end

  def show_application_preference
    boolean_cast_setting 'setting_show_application'
  end

  def theme_preference
    settings['setting_theme']
  end

  def default_language_preference
    settings['setting_default_language']
  end

  def aggregate_reblogs_preference
    boolean_cast_setting 'setting_aggregate_reblogs'
  end

  def advanced_layout_preference
    boolean_cast_setting 'setting_advanced_layout'
  end

  def use_blurhash_preference
    boolean_cast_setting 'setting_use_blurhash'
  end

  def use_pending_items_preference
    boolean_cast_setting 'setting_use_pending_items'
  end

  def trends_preference
    boolean_cast_setting 'setting_trends'
  end

  def crop_images_preference
    boolean_cast_setting 'setting_crop_images'
  end

  def always_send_emails_preference
    boolean_cast_setting 'setting_always_send_emails'
  end

  def notification_sound_preference
    settings['setting_notification_sound']
  end

  def boolean_cast_setting(key)
    ActiveModel::Type::Boolean.new.cast(settings[key])
  end

  def coerced_settings(key)
    coerce_values settings.fetch(key, {})
  end

  def coerce_values(params_hash)
    params_hash.transform_values { |x| ActiveModel::Type::Boolean.new.cast(x) }
  end

  def change?(key)
    !settings[key].nil?
  end

  def update_if_changed(key, pref, setting_key)
    user.settings[key] = pref if change?(setting_key)
  end
end
