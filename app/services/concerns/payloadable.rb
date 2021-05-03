# frozen_string_literal: true

module Payloadable
  def serialize_payload(record, serializer, options = {})
    signer    = options.delete(:signer)
    sign_with = options.delete(:sign_with)
    payload   = ActiveModelSerializers::SerializableResource.new(record, options.merge(serializer: serializer, adapter: ActivityPub::Adapter)).as_json
    object    = record.respond_to?(:virtual_object) ? record.virtual_object : record

    if (object.respond_to?(:sign?) && object.sign?) && signer && signing_enabled?
      ActivityPub::LinkedDataSignature.new(payload).sign!(signer, sign_with: sign_with)
    else
      payload
    end
  end

  def signing_enabled?
    ENV['AUTHORIZED_FETCH'] != 'true' && !Rails.configuration.x.whitelist_mode
  end
end
