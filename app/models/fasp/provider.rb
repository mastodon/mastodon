# frozen_string_literal: true

# == Schema Information
#
# Table name: fasp_providers
#
#  id                      :bigint(8)        not null, primary key
#  base_url                :string           not null
#  confirmed               :boolean          default(FALSE), not null
#  contact_email           :string
#  delivery_last_failed_at :datetime
#  fediverse_account       :string
#  name                    :string           not null
#  privacy_policy          :jsonb
#  provider_public_key_pem :string           not null
#  remote_identifier       :string           not null
#  server_private_key_pem  :string           not null
#  sign_in_url             :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class Fasp::Provider < ApplicationRecord
  include DebugConcern

  RETRY_INTERVAL = 1.hour

  has_many :fasp_backfill_requests, inverse_of: :fasp_provider, class_name: 'Fasp::BackfillRequest', dependent: :delete_all
  has_many :fasp_debug_callbacks, inverse_of: :fasp_provider, class_name: 'Fasp::DebugCallback', dependent: :delete_all
  has_many :fasp_subscriptions, inverse_of: :fasp_provider, class_name: 'Fasp::Subscription', dependent: :delete_all
  has_many :fasp_capabilities, inverse_of: :fasp_provider, class_name: 'Fasp::Capability', dependent: :delete_all

  validates :name, presence: true
  validates :base_url, presence: true, url: true
  validates :provider_public_key_pem, presence: true
  validates :remote_identifier, presence: true

  before_create :create_keypair

  scope :confirmed, -> { where(confirmed: true) }
  scope :with_capability, lambda { |capability_name|
    joins(:fasp_capabilities).where(fasp_capabilities: { name: capability_name, enabled: true })
  }

  accepts_nested_attributes_for :fasp_capabilities

  def enabled_capabilities
    fasp_capabilities.select(&:enabled).map(&:id)
  end

  def capability_enabled?(capability_name)
    return false unless confirmed?

    fasp_capabilities.exists?(name: capability_name, enabled: true)
  end

  def server_private_key
    @server_private_key ||= OpenSSL::PKey.read(server_private_key_pem)
  end

  def server_public_key_base64
    Base64.strict_encode64(server_private_key.raw_public_key)
  end

  def provider_public_key_base64=(string)
    return if string.blank?

    self.provider_public_key_pem =
      OpenSSL::PKey.new_raw_public_key(
        'ed25519',
        Base64.strict_decode64(string)
      ).public_to_pem
  end

  def provider_public_key
    @provider_public_key ||= OpenSSL::PKey.read(provider_public_key_pem)
  end

  def provider_public_key_raw
    provider_public_key.raw_public_key
  end

  def provider_public_key_fingerprint
    OpenSSL::Digest.base64digest('sha256', provider_public_key_raw)
  end

  def url(path)
    base = base_url
    base = base.chomp('/') if path.start_with?('/')
    "#{base}#{path}"
  end

  def update_info!(confirm: false)
    self.class.transaction do
      self.confirmed = true if confirm
      provider_info = Fasp::Request.new(self).get('/provider_info')
      assign_attributes(
        privacy_policy: provider_info['privacyPolicy'],
        sign_in_url: provider_info['signInUrl'],
        contact_email: provider_info['contactEmail'],
        fediverse_account: provider_info['fediverseAccount']
      )
      capabilities_info = provider_info['capabilities'] || []
      fasp_capabilities.where.not(name: capabilities_info.map { |c| c['id'] }).destroy_all
      capabilities_info.each do |capability_info|
        fasp_capabilities.find_or_create_by!(name: capability_info['id'], version: capability_info['version'])
      end
      save!
    end
  end

  def delivery_failure_tracker
    @delivery_failure_tracker ||= DeliveryFailureTracker.new(base_url, resolution: :minutes)
  end

  def available?
    delivery_failure_tracker.available? || retry_worthwile?
  end

  def update_availability!
    self.delivery_last_failed_at = (Time.current unless delivery_failure_tracker.available?)

    save!
  end

  private

  def create_keypair
    self.server_private_key_pem ||=
      OpenSSL::PKey.generate_key('ed25519').private_to_pem
  end

  def retry_worthwile?
    delivery_last_failed_at && delivery_last_failed_at < RETRY_INTERVAL.ago
  end
end
