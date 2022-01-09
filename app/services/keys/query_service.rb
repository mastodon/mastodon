# frozen_string_literal: true

class Keys::QueryService < BaseService
  include JsonLdHelper

  class Result < ActiveModelSerializers::Model
    attributes :account, :devices

    def initialize(account, devices)
      super(
        account: account,
        devices: devices || [],
      )
    end

    def find(device_id)
      @devices.find { |device| device.device_id == device_id }
    end
  end

  class Device < ActiveModelSerializers::Model
    attributes :device_id, :name, :identity_key, :fingerprint_key

    def initialize(attributes = {})
      super(
        device_id:       attributes[:device_id],
        name:            attributes[:name],
        identity_key:    attributes[:identity_key],
        fingerprint_key: attributes[:fingerprint_key],
      )
      @claim_url = attributes[:claim_url]
    end

    def valid_claim_url?
      return false if @claim_url.blank?

      begin
        parsed_url = Addressable::URI.parse(@claim_url).normalize
      rescue Addressable::URI::InvalidURIError
        return false
      end

      %w(http https).include?(parsed_url.scheme) && parsed_url.host.present?
    end
  end

  def call(account)
    @account = account

    if @account.local?
      query_local_devices!
    else
      query_remote_devices!
    end

    Result.new(@account, @devices)
  end

  private

  def query_local_devices!
    @devices = @account.devices.map { |device| Device.new(device) }
  end

  def query_remote_devices!
    return if @account.devices_url.blank?

    json = fetch_resource(@account.devices_url)

    return if json['items'].blank?

    @devices = json['items'].map do |device|
      Device.new(device_id: device['id'], name: device['name'], identity_key: device.dig('identityKey', 'publicKeyBase64'), fingerprint_key: device.dig('fingerprintKey', 'publicKeyBase64'), claim_url: device['claim'])
    end
  rescue HTTP::Error, OpenSSL::SSL::SSLError, Mastodon::Error => e
    Rails.logger.debug "Querying devices for #{@account.acct} failed: #{e}"
    nil
  end
end
