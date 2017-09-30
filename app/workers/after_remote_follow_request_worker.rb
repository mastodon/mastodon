# frozen_string_literal: true

class AfterRemoteFollowRequestWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 5

  attr_reader :follow_request

  def perform(follow_request_id)
    @follow_request = FollowRequest.find(follow_request_id)
    process_follow_service if processing_required?
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def process_follow_service
    follow_request.destroy
    FollowService.new.call(follow_request.account, updated_account.acct)
  end

  def processing_required?
    !updated_account.nil? && !updated_account.locked?
  end

  def updated_account
    @_updated_account ||= FetchRemoteAccountService.new.call(follow_request.target_account.remote_url)
  end
end
