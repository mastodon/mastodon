# frozen_string_literal: true

class Form::AdminSettings
  include ActiveModel::Model

  include AuthorizedFetchHelper

  KEYS = %i(
    site_contact_username
    site_contact_email
    site_title
    site_short_description
    site_extended_description
    site_terms
    registrations_mode
    closed_registrations_message
    bootstrap_timeline_accounts
    theme
    activity_api_enabled
    peers_api_enabled
    preview_sensitive_media
    custom_css
    profile_directory
    thumbnail
    mascot
    trends
    trendable_by_default
    show_domain_blocks
    show_domain_blocks_rationale
    allow_referrer_origin
    noindex
    require_invite_text
    media_cache_retention_period
    content_cache_retention_period
    backups_retention_period
    status_page_url
    captcha_enabled
    authorized_fetch
    app_icon
    favicon
    min_age
    local_live_feed_access
    remote_live_feed_access
    local_topic_feed_access
    remote_topic_feed_access
    landing_page
    wrapstodon
  ).freeze

  INTEGER_KEYS = %i(
    media_cache_retention_period
    content_cache_retention_period
    backups_retention_period
    min_age
  ).freeze

  BOOLEAN_KEYS = %i(
    allow_referrer_origin
    timeline_preview
    activity_api_enabled
    peers_api_enabled
    preview_sensitive_media
    profile_directory
    trends
    trendable_by_default
    noindex
    require_invite_text
    captcha_enabled
    authorized_fetch
    wrapstodon
  ).freeze

  UPLOAD_KEYS = %i(
    thumbnail
    mascot
    app_icon
    favicon
  ).freeze

  DIGEST_KEYS = %i(
    custom_css
  ).freeze

  OVERRIDEN_SETTINGS = {
    authorized_fetch: :authorized_fetch_mode?,
  }.freeze

  DESCRIPTION_LIMIT = 200
  DOMAIN_BLOCK_AUDIENCES = %w(disabled users all).freeze
  REGISTRATION_MODES = %w(open approved none).freeze
  FEED_ACCESS_MODES = %w(public authenticated disabled).freeze
  ALTERNATE_FEED_ACCESS_MODES = %w(public authenticated).freeze
  LANDING_PAGE = %w(trends about local_feed).freeze

  attr_accessor(*KEYS)

  validates :registrations_mode, inclusion: { in: REGISTRATION_MODES }, if: -> { defined?(@registrations_mode) }
  validates :site_contact_email, :site_contact_username, presence: true, if: -> { defined?(@site_contact_username) || defined?(@site_contact_email) }
  validates :site_contact_username, existing_username: true, if: -> { defined?(@site_contact_username) }
  validates :bootstrap_timeline_accounts, existing_username: { multiple: true }, if: -> { defined?(@bootstrap_timeline_accounts) }
  validates :show_domain_blocks, inclusion: { in: DOMAIN_BLOCK_AUDIENCES }, if: -> { defined?(@show_domain_blocks) }
  validates :show_domain_blocks_rationale, inclusion: { in: DOMAIN_BLOCK_AUDIENCES }, if: -> { defined?(@show_domain_blocks_rationale) }
  validates :local_live_feed_access, inclusion: { in: FEED_ACCESS_MODES }, if: -> { defined?(@local_live_feed_access) }
  validates :remote_live_feed_access, inclusion: { in: FEED_ACCESS_MODES }, if: -> { defined?(@remote_live_feed_access) }
  validates :local_topic_feed_access, inclusion: { in: ALTERNATE_FEED_ACCESS_MODES }, if: -> { defined?(@local_topic_feed_access) }
  validates :remote_topic_feed_access, inclusion: { in: FEED_ACCESS_MODES }, if: -> { defined?(@remote_topic_feed_access) }
  validates :media_cache_retention_period, :content_cache_retention_period, :backups_retention_period, numericality: { only_integer: true }, allow_blank: true, if: -> { defined?(@media_cache_retention_period) || defined?(@content_cache_retention_period) || defined?(@backups_retention_period) }
  validates :min_age, numericality: { only_integer: true }, allow_blank: true, if: -> { defined?(@min_age) }
  validates :site_short_description, length: { maximum: DESCRIPTION_LIMIT }, if: -> { defined?(@site_short_description) }
  validates :status_page_url, url: true, allow_blank: true
  validate :validate_site_uploads
  validates :landing_page, inclusion: { in: LANDING_PAGE }, if: -> { defined?(@landing_page) }

  KEYS.each do |key|
    define_method(key) do
      return instance_variable_get(:"@#{key}") if instance_variable_defined?(:"@#{key}")

      stored_value = if UPLOAD_KEYS.include?(key)
                       SiteUpload.where(var: key).first_or_initialize(var: key)
                     elsif OVERRIDEN_SETTINGS.include?(key)
                       public_send(OVERRIDEN_SETTINGS[key])
                     else
                       Setting.public_send(key)
                     end

      instance_variable_set(:"@#{key}", stored_value)
    end
  end

  UPLOAD_KEYS.each do |key|
    define_method(:"#{key}=") do |file|
      value = public_send(key)
      value.file = file
    rescue Mastodon::DimensionsValidationError => e
      errors.add(key.to_sym, e.message)
    end
  end

  def save
    # NOTE: Annoyingly, files are processed and can error out before
    # validations are called, and `valid?` clears errors…
    # So for now, return early if errors aren't empty.
    return false unless errors.empty? && valid?

    KEYS.each do |key|
      next unless instance_variable_defined?(:"@#{key}")

      cache_digest_value(key) if DIGEST_KEYS.include?(key)

      if UPLOAD_KEYS.include?(key)
        public_send(key).save
      else
        setting = Setting.where(var: key).first_or_initialize(var: key)
        setting.update(value: typecast_value(key, instance_variable_get(:"@#{key}")))
      end
    end
  end

  def persisted?
    true
  end

  private

  def cache_digest_value(key)
    Rails.cache.delete(:"setting_digest_#{key}")

    key_value = instance_variable_get(:"@#{key}")
    if key_value.present?
      Rails.cache.write(
        :"setting_digest_#{key}",
        Digest::SHA256.hexdigest(key_value)
      )
    end
  end

  def typecast_value(key, value)
    if BOOLEAN_KEYS.include?(key)
      value == '1'
    elsif INTEGER_KEYS.include?(key)
      value.blank? ? value : Integer(value)
    else
      value
    end
  end

  def validate_site_uploads
    UPLOAD_KEYS.each do |key|
      next unless instance_variable_defined?(:"@#{key}")

      upload = instance_variable_get(:"@#{key}")
      next if upload.valid?

      upload.errors.each do |error|
        errors.import(error, attribute: key)
      end
    end
  end
end
