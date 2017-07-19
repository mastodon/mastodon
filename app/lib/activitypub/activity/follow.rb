# frozen_string_literal: true

class ActivityPub::Activity::Follow < ActivityPub::Activity
  def perform
    target_account = account_from_uri(object_uri)

    return unless target_account.local?

    follow = @account.follow!(target_account)
    NotifyService.new.call(target_account, follow)
  end
end
