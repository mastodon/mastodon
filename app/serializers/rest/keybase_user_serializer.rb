# frozen_string_literal: true

class REST::KeybaseUserSerializer < ActiveModel::Serializer
  include RoutingHelper
  attributes :avatar, :signatures

  def avatar
    full_asset_url(object.avatar_original_url)
  end

  def signatures
    kb_proofs = instance_options[:proofs]
    kb_proofs.map { |proof| { sig_hash: proof.token, kb_username: proof.provider_username } }
  end
end
