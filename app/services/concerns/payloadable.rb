# frozen_string_literal: true

module Payloadable
  def serialize_payload(record, serializer, options = {})
    signer    = options.delete(:signer)
    sign_with = options.delete(:sign_with)
    payload   = ActiveModelSerializers::SerializableResource.new(record, options.merge(serializer: serializer, adapter: ActivityPub::Adapter, allow_private: true)).as_json

    if (record.respond_to?(:sign?) && record.sign?) && signer && signing_enabled?
      ActivityPub::LinkedDataSignature.new(payload).sign!(signer, sign_with: sign_with)
    else
      payload
    end
  end

  def signing_enabled?
    ENV['AUTHORIZED_FETCH'] != 'true' && !Rails.configuration.x.whitelist_mode
  end
end
