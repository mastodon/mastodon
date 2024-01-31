# frozen_string_literal: true

class REST::Keys::ClaimResultSerializer < REST::BaseSerializer
  attributes :account_id, :device_id, :key_id, :key, :signature

  def account_id
    object.account.id.to_s
  end
end
