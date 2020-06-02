# frozen_string_literal: true

class REST::EncryptedMessageSerializer < ActiveModel::Serializer
  attributes :id, :account_id, :device_id,
             :type, :body, :digest, :message_franking

  def id
    object.id.to_s
  end

  def account_id
    object.from_account_id.to_s
  end

  def device_id
    object.from_device_id
  end
end
