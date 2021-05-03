# frozen_string_literal: true

class REST::MutedAccountSerializer < REST::AccountSerializer
  attribute :mute_expires_at

  def mute_expires_at
    mute = current_user.account.mute_relationships.find_by(target_account_id: object.id)
    mute && !mute.expired? ? mute.expires_at : nil
  end
end
