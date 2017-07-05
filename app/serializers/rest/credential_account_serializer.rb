# frozen_string_literal: true

class REST::CredentialAccountSerializer < REST::AccountSerializer
  attributes :default_privacy

  def default_privacy
    object.user.setting_default_privacy
  end
end
