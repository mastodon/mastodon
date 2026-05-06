# frozen_string_literal: true

# == Schema Information
#
# Table name: fasp_providers
#
#  id                      :bigint(8)        not null, primary key
#  base_url                :string           not null
#  capabilities            :jsonb            not null
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

  validates :name, presence: true
  validates :base_url, presence: true, url: true
  validates :provider_public_key_pem, presence: true
  validates :remote_identifier, presence: true

  before_create :create_keypair
  after_commit :update_remote_capabilities

  scope :confirmed, -> { where(confirmed: true) }
  scope :with_capability, lambda { |capability_name|
    where('fasp_providers.capabilities @> ?::jsonb', "[{\"id\": \"#{capability_name}\", \"enabled\": true}]")
  }

  def capabilities
    read_attribute(:capabilities).map do |attributes|
      Fasp::Capability.new(attributes)
    end
  end

  def capabilities_attributes=(attributes)
    capability_objects = attributes.values.map { |a| Fasp::Capability.new(a) }
    self[:capabilities] = capability_objects.map(&:attributes)
  end

  def enabled_capabilities
    capabilities.select(&:enabled).map(&:id)
  end

  def capability?(capability_name)
    return false unless confirmed?

    capabilities.present? && capabilities.any? do |capability|
      capability.id == capability_name
    end
  end

  def capability_enabled?(capability_name)
    return false unless confirmed?

    capabilities.present? && capabilities.any? do |capability|
      capability.id == capability_name && capability.enabled
    end
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
    self.confirmed = true if confirm
    provider_info = Fasp::Request.new(self).get('/provider_info')
    assign_attributes(
      privacy_policy: provider_info['privacyPolicy'],
      capabilities: provider_info['capabilities'],
      sign_in_url: provider_info['signInUrl'],
      contact_email: provider_info['contactEmail'],
      fediverse_account: provider_info['fediverseAccount']
    )
    save!
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

  def update_remote_capabilities
    return unless saved_change_to_attribute?(:capabilities)

    old, current = saved_change_to_attribute(:capabilities)
    old ||= []
    current.each do |capability|
      update_remote_capability(capability) if capability.key?('enabled') && !old.include?(capability)
    end
  end

  def update_remote_capability(capability)
    version, = capability['version'].split('.')
    path = "/capabilities/#{capability['id']}/#{version}/activation"
    if capability['enabled']
      Fasp::Request.new(self).post(path)
    else
      Fasp::Request.new(self).delete(path)
    end
  end

  def retry_worthwile?
    delivery_last_failed_at && delivery_last_failed_at < RETRY_INTERVAL.ago
  end
end
