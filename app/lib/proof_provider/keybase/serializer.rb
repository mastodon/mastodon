# frozen_string_literal: true

class ProofProvider::Keybase::Serializer < ActiveModel::Serializer
  include RoutingHelper

  attribute :avatar

  has_many :identity_proofs, key: :signatures

  def avatar
    full_asset_url(object.avatar_original_url)
  end

  class AccountIdentityProofSerializer < ActiveModel::Serializer
    attributes :sig_hash, :kb_username

    def sig_hash
      object.token
    end

    def kb_username
      object.provider_username
    end
  end
end
