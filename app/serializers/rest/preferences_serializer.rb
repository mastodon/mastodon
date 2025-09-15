# frozen_string_literal: true

class REST::PreferencesSerializer < ActiveModel::Serializer
  attribute :posting_default_privacy, key: 'posting:default:visibility'
  attribute :posting_default_sensitive, key: 'posting:default:sensitive'
  attribute :posting_default_language, key: 'posting:default:language'
  attribute :posting_default_quote_policy, key: 'posting:default:quote_policy'

  attribute :reading_default_sensitive_media, key: 'reading:expand:media'
  attribute :reading_default_sensitive_text, key: 'reading:expand:spoilers'
  attribute :reading_autoplay_gifs, key: 'reading:autoplay:gifs'

  def posting_default_privacy
    object.user.setting_default_privacy
  end

  def posting_default_quote_policy
    object.user.setting_default_quote_policy
  end

  def posting_default_sensitive
    object.user.setting_default_sensitive
  end

  def posting_default_language
    object.user.preferred_posting_language
  end

  def reading_default_sensitive_media
    object.user.setting_display_media
  end

  def reading_default_sensitive_text
    object.user.setting_expand_spoilers
  end

  def reading_autoplay_gifs
    object.user.setting_auto_play_gif
  end
end
