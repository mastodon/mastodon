# frozen_string_literal: true

class ActivityPub::Activity::Update < ActivityPub::Activity
  def perform
    dereference_object!

    if equals_or_includes_any?(@object['type'], %w(Application Group Organization Person Service))
      update_account
    elsif equals_or_includes_any?(@object['type'], %w(Note Question))
      update_status
    end
  end

  private

  def update_account
    return reject_payload! if @account.uri != object_uri

    ActivityPub::ProcessAccountService.new.call(@account.username, @account.domain, @object, signed_with_known_key: true)
  end

  def update_status
    return reject_payload! if invalid_origin?(object_uri)

    @status = Status.find_by(uri: object_uri, account_id: @account.id)

    return if @status.nil?

    ActivityPub::ProcessStatusUpdateService.new.call(@status, @object)
  end
end
