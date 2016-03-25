class PostStatusService < BaseService
  # Post a text status update, fetch and notify remote users mentioned
  # @param [Account] account Account from which to post
  # @param [String] text Message
  # @param [Status] in_reply_to Optional status to reply to
  # @return [Status]
  def call(account, text, in_reply_to = nil)
    status = account.statuses.create!(text: text, thread: in_reply_to)
    process_mentions_service.(status)
    DistributionWorker.perform_async(status.id)
    account.ping!(account_url(account, format: 'atom'), [Rails.configuration.x.hub_url])
    status
  end

  private

  def process_mentions_service
    @process_mentions_service ||= ProcessMentionsService.new
  end
end
