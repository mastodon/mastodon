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
    timeline_preview
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
    trends_as_landing_page
    trendable_by_default
    show_domain_blocks
    show_domain_blocks_rationale
    noindex
    require_invite_text
    media_cache_retention_period
    content_cache_retention_period
    backups_retention_period
    status_page_url
    captcha_enabled
    authorized_fetch
  ).freeze

  INTEGER_KEYS = %i(
    media_cache_retention_period
    content_cache_retention_period
    backups_retention_period
  ).freeze

  BOOLEAN_KEYS = %i(
    timeline_preview
    activity_api_enabled
    peers_api_enabled
    preview_sensitive_media
    profile_directory
    trends
    trends_as_landing_page
    trendable_by_default
    noindex
    require_invite_text
    captcha_enabled
    authorized_fetch
  ).freeze

  UPLOAD_KEYS = %i(
    thumbnail
    mascot
  ).freeze

  OVERRIDEN_SETTINGS = {
    authorized_fetch: :authorized_fetch_mode?,
  }.freeze

  attr_accessor(*KEYS)

  validates :registrations_mode, inclusion: { in: %w(open approved none) }, if: -> { defined?(@registrations_mode) }
  validates :site_contact_email, :site_contact_username, presence: true, if: -> { defined?(@site_contact_username) || defined?(@site_contact_email) }
  validates :site_contact_username, existing_username: true, if: -> { defined?(@site_contact_username) }
  validates :bootstrap_timeline_accounts, existing_username: { multiple: true }, if: -> { defined?(@bootstrap_timeline_accounts) }
  validates :show_domain_blocks, inclusion: { in: %w(disabled users all) }, if: -> { defined?(@show_domain_blocks) }
  validates :show_domain_blocks_rationale, inclusion: { in: %w(disabled users all) }, if: -> { defined?(@show_domain_blocks_rationale) }
  validates :media_cache_retention_period, :content_cache_retention_period, :backups_retention_period, numericality: { only_integer: true }, allow_blank: true, if: -> { defined?(@media_cache_retention_period) || defined?(@content_cache_retention_period) || defined?(@backups_retention_period) }
  validates :site_short_description, length: { maximum: 200 }, if: -> { defined?(@site_short_description) }
  validates :status_page_url, url: true, allow_blank: true
  validate :validate_site_uploads

  KEYS.each do |key|
    define_method(key) do
      return instance_variable_get("@#{key}") if instance_variable_defined?("@#{key}")

      stored_value = if UPLOAD_KEYS.include?(key)
                       SiteUpload.where(var: key).first_or_initialize(var: key)
                     elsif OVERRIDEN_SETTINGS.include?(key)
                       public_send(OVERRIDEN_SETTINGS[key])
                     else
                       Setting.public_send(key)
                     end

      instance_variable_set("@#{key}", stored_value)
    end
  end

  UPLOAD_KEYS.each do |key|
    define_method("#{key}=") do |file|
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
      next unless instance_variable_defined?("@#{key}")

      if UPLOAD_KEYS.include?(key)
        public_send(key).save
      else
        setting = Setting.where(var: key).first_or_initialize(var: key)
        setting.update(value: typecast_value(key, instance_variable_get("@#{key}")))
      end
    end
  end

  private

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
      next unless instance_variable_defined?("@#{key}")

      upload = instance_variable_get("@#{key}")
      next if upload.valid?

      upload.errors.each do |error|
        errors.import(error, attribute: key)
      end
    end
  end
end
