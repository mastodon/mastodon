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
    user.settings['notification_emails'] = merged_notification_emails
    user.settings['interactions'] = merged_interactions
    user.settings['default_privacy'] = default_privacy_preference
    user.settings['default_sensitive'] = default_sensitive_preference
    user.settings['unfollow_modal'] = unfollow_modal_preference
    user.settings['boost_modal'] = boost_modal_preference
    user.settings['delete_modal'] = delete_modal_preference
    user.settings['auto_play_gif'] = auto_play_gif_preference
    user.settings['system_font_ui'] = system_font_ui_preference
    user.settings['noindex'] = noindex_preference
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

  def noindex_preference
    boolean_cast_setting 'setting_noindex'
  end

  def boolean_cast_setting(key)
    settings[key] == '1'
  end

  def coerced_settings(key)
    coerce_values settings.fetch(key, {})
  end

  def coerce_values(params_hash)
    params_hash.transform_values { |x| x == '1' }
  end
end
