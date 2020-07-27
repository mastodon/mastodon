# frozen_string_literal: true

class DeliverToDeviceService < BaseService
  include Payloadable

  class EncryptedMessage < ActiveModelSerializers::Model
    attributes :source_account, :target_account, :source_device,
               :target_device_id, :type, :body, :digest,
               :message_franking
  end

  def call(source_account, source_device, options = {})
    @source_account   = source_account
    @source_device    = source_device
    @target_account   = Account.find(options[:account_id])
    @target_device_id = options[:device_id]
    @body             = options[:body]
    @type             = options[:type]
    @hmac             = options[:hmac]

    set_message_franking!

    if @target_account.local?
      deliver_to_local!
    else
      deliver_to_remote!
    end
  end

  private

  def set_message_franking!
    @message_franking = message_franking.to_token
  end

  def deliver_to_local!
    target_device = @target_account.devices.find_by!(device_id: @target_device_id)

    target_device.encrypted_messages.create!(
      from_account: @source_account,
      from_device_id: @source_device.device_id,
      type: @type,
      body: @body,
      digest: @hmac,
      message_franking: @message_franking
    )
  end

  def deliver_to_remote!
    ActivityPub::DeliveryWorker.perform_async(
      Oj.dump(serialize_payload(ActivityPub::ActivityPresenter.from_encrypted_message(encrypted_message), ActivityPub::ActivitySerializer)),
      @source_account.id,
      @target_account.inbox_url
    )
  end

  def message_franking
    MessageFranking.new(
      source_account_id: @source_account.id,
      target_account_id: @target_account.id,
      hmac: @hmac,
      timestamp: Time.now.utc
    )
  end

  def encrypted_message
    EncryptedMessage.new(
      source_account: @source_account,
      target_account: @target_account,
      source_device: @source_device,
      target_device_id: @target_device_id,
      type: @type,
      body: @body,
      digest: @hmac,
      message_franking: @message_franking
    )
  end
end
