# frozen_string_literal: true

class ActivityPub::Activity::Update < ActivityPub::Activity
  def perform
    case @object['type']
    when 'Person'
      update_account
    end
  end

  private

  def update_account
    return if @account.uri != object_uri
    ActivityPub::ProcessAccountService.new.call(@account.username, @account.domain, @object)
  end
end
