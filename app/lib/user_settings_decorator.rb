# frozen_string_literal: true

class UserSettingsDecorator
  attr_reader :user, :settings

  NESTED_KEYS = %w(
    notification_emails
    interactions
  ).freeze

  BOOLEAN_KEYS = %w(
    default_sensitive
    unfollow_modal
    boost_modal
    delete_modal
    mention_modal
    auto_play_gif
    expand_spoiers
    reduce_motion
    disable_swiping
    system_font_ui
    noindex
    aggregate_reblogs
    show_application
    advanced_layout
    use_blurhash
    use_pending_items
    trends
    crop_images
    always_send_emails
  ).freeze

  STRING_KEYS = %w(
    default_privacy
    default_language
    theme
    display_media
  ).freeze

  def initialize(user)
    @user = user
  end

  def update(settings)
    @settings = settings
    process_update
  end

  private

  def process_update
    NESTED_KEYS.each do |key|
      user.settings[key] = user.settings[key].merge coerced_settings(key) if change?(key)
    end

    STRING_KEYS.each do |key|
      user.settings[key] = settings["setting_#{key}"] if change?("setting_#{key}")
    end

    BOOLEAN_KEYS.each do |key|
      user.settings[key] = boolean_cast_setting "setting_#{key}" if change?("setting_#{key}")
    end
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
end
