# frozen_string_literal: true

class REST::CredentialAccountSerializer < REST::AccountSerializer
  attributes :source

  def source
    user = object.user
    {
      privacy: user.setting_default_privacy,
      sensitive: user.setting_default_sensitive,
      note: object.note,
    }
  end
end
