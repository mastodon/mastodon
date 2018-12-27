class REST::KeybaseProofSerializer < ActiveModel::Serializer
  attribute :token, key: :sig_hash
  attribute :provider_username, key: :kb_username
end
