# frozen_string_literal: true

class ActivityPub::Activity::Update < ActivityPub::Activity
  def perform
    update_account if equals_or_includes?(@object['type'], 'Person')
  end

  private

  def update_account
    return if @account.uri != object_uri
    ActivityPub::ProcessAccountService.new.call(@account.username, @account.domain, @object)
  end
end
