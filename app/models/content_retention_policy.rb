# frozen_string_literal: true

class ContentRetentionPolicy
  def self.current
    new
  end

  def media_cache_retention_period
    retention_period Setting.media_cache_retention_period
  end

  def content_cache_retention_period
    retention_period Setting.content_cache_retention_period
  end

  def backups_retention_period
    retention_period Setting.backups_retention_period
  end

  private

  def retention_period(value)
    value.days if value.is_a?(Integer) && value.positive?
  end
end
