# frozen_string_literal: true

class REST::IdentityProofSerializer < ActiveModel::Serializer
  attributes :provider, :provider_username, :updated_at, :proof_url, :profile_url

  def proof_url
    object.badge.proof_url
  end

  def profile_url
    object.badge.profile_url
  end

  def provider
    object.provider.capitalize
  end
end
