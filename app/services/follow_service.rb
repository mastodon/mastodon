class FollowService
  def call(source_account, uri)
    target_account = follow_remote_account_service.(uri)
    source_account.follow!(target_account) unless target_account.nil?
  end

  private

  def follow_remote_account_service
    FollowRemoteAccountService.new
  end
end
