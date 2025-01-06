# frozen_string_literal: true

# == Schema Information
#
# Table name: fasp_providers
#
#  id                      :bigint(8)        not null, primary key
#  base_url                :string           not null
#  capabilities            :jsonb
#  confirmed               :boolean          default(FALSE), not null
#  contact_email           :string
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

  has_many :fasp_backfill_requests, inverse_of: :fasp_provider, class_name: 'Fasp::BackfillRequest', dependent: :delete_all
  has_many :fasp_debug_callbacks, inverse_of: :fasp_provider, class_name: 'Fasp::DebugCallback', dependent: :delete_all
  has_many :fasp_subscriptions, inverse_of: :fasp_provider, class_name: 'Fasp::Subscription', dependent: :delete_all

  before_create :create_keypair

  def enabled_capabilities=(hash)
    capabilities.each do |capability|
      capability['enabled'] = hash[capability['id']] == '1'
    end
    save!
  end

  def capability?(capability_name, only_enabled: true)
    return false unless confirmed?

    capabilities.present? && capabilities.any? do |capability|
      capability['id'] == capability_name &&
        (only_enabled ? capability['enabled'] : true)
    end
  end

  def server_private_key
    @server_private_key ||= OpenSSL::PKey.read(server_private_key_pem)
  end

  def server_public_key_base64
    Base64.strict_encode64(server_private_key.raw_public_key)
  end

  def provider_public_key_base64=(string)
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

  private

  def create_keypair
    self.server_private_key_pem =
      OpenSSL::PKey.generate_key('ed25519').private_to_pem
  end
end
