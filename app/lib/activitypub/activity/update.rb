# frozen_string_literal: true

class ActivityPub::Activity::Update < ActivityPub::Activity
  SUPPORTED_TYPES = %w(Application Group Organization Person Service).freeze

  def perform
    update_account if equals_or_includes_any?(@object['type'], SUPPORTED_TYPES)
  end

  private

  def update_account
    return if @account.uri != object_uri

    ActivityPub::ProcessAccountService.new.call(@account.username, @account.domain, @object, signed_with_known_key: true)
  end
end
