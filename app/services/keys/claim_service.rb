# frozen_string_literal: true

class Keys::ClaimService < BaseService
  HEADERS = { 'Content-Type' => 'application/activity+json' }.freeze

  class Result < ActiveModelSerializers::Model
    attributes :account, :device_id, :key_id,
               :key, :signature

    def initialize(account, device_id, key_attributes = {})
      super(
        account:   account,
        device_id: device_id,
        key_id:    key_attributes[:key_id],
        key:       key_attributes[:key],
        signature: key_attributes[:signature],
      )
    end
  end

  def call(source_account, target_account_id, device_id)
    @source_account = source_account
    @target_account = Account.find(target_account_id)
    @device_id      = device_id

    if @target_account.local?
      claim_local_key!
    else
      claim_remote_key!
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end

  private

  def claim_local_key!
    device = @target_account.devices.find_by(device_id: @device_id)
    key    = nil

    ApplicationRecord.transaction do
      key = device.one_time_keys.order(Arel.sql('random()')).first!
      key.destroy!
    end

    @result = Result.new(@target_account, @device_id, key)
  end

  def claim_remote_key!
    query_result = QueryService.new.call(@target_account)
    device       = query_result.find(@device_id)

    return unless device.present? && device.valid_claim_url?

    json = fetch_resource_with_post(device.claim_url)

    return unless json.present? && json['publicKeyBase64'].present?

    @result = Result.new(@target_account, @device_id, key_id: json['id'], key: json['publicKeyBase64'], signature: json.dig('signature', 'signatureValue'))
  rescue HTTP::Error, OpenSSL::SSL::SSLError, Mastodon::Error => e
    Rails.logger.debug "Claiming one-time key for #{@target_account.acct}:#{@device_id} failed: #{e}"
    nil
  end

  def fetch_resource_with_post(uri)
    build_post_request(uri).perform do |response|
      raise Mastodon::UnexpectedResponseError, response unless response_successful?(response) || response_error_unsalvageable?(response)

      body_to_json(response.body_with_limit) if response.code == 200
    end
  end

  def build_post_request(uri)
    Request.new(:post, uri).tap do |request|
      request.on_behalf_of(@source_account)
      request.add_headers(HEADERS)
    end
  end
end
