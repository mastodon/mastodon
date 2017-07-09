# frozen_string_literal: true

class REST::CredentialAccountSerializer < REST::AccountSerializer
  attributes :raw_note, :default_privacy

  def raw_note
    object.note
  end

  def default_privacy
    object.user.setting_default_privacy
  end
end
