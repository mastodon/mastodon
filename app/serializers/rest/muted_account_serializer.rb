# frozen_string_literal: true

class REST::MutedAccountSerializer < REST::AccountSerializer
  attribute :mute_expires_at, if: :current_user?

  def current_user?
    defined?(current_user) && !current_user.nil?
  end

  def mute_expires_at
    mute = current_user.account&.mute_relationships&.find_by(target_account_id: object.id)
    mute && !mute.expired? ? mute.expires_at : nil
  end
end
