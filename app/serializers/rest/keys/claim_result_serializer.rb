# frozen_string_literal: true

class REST::Keys::ClaimResultSerializer < ActiveModel::Serializer
  attributes :account_id, :device_id, :key_id, :key, :signature

  def account_id
    object.account.id.to_s
  end
end
