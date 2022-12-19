class REST::Keys::DeviceSerializer < ActiveModel::Serializer
  attributes :device_id, :name, :identity_key,
             :fingerprint_key
end
