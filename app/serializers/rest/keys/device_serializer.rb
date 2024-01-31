# frozen_string_literal: true

class REST::Keys::DeviceSerializer < REST::BaseSerializer
  attributes :device_id, :name, :identity_key,
             :fingerprint_key
end
