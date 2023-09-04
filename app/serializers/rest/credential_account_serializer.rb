# frozen_string_literal: true

class REST::CredentialAccountSerializer < REST::AccountSerializer
  attributes :source

  has_one :role, serializer: REST::RoleSerializer

  def source
    user = object.user

    {
      privacy: user.setting_default_privacy,
      sensitive: user.setting_default_sensitive,
      language: user.setting_default_language,
      note: object.note,
      fields: object.fields.map(&:to_h),
      follow_requests_count: FollowRequest.where(target_account: object).limit(40).count,
    }
  end

  def role
    object.user_role
  end
end
