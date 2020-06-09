# frozen_string_literal: true

class MessageFranking
  attr_reader :hmac, :source_account_id, :target_account_id,
              :timestamp, :original_franking

  def initialize(attributes = {})
    @hmac              = attributes[:hmac]
    @source_account_id = attributes[:source_account_id]
    @target_account_id = attributes[:target_account_id]
    @timestamp         = attributes[:timestamp]
    @original_franking = attributes[:original_franking]
  end

  def to_token
    crypt = ActiveSupport::MessageEncryptor.new(SystemKey.current_key, serializer: Oj)
    crypt.encrypt_and_sign(self)
  end
end
