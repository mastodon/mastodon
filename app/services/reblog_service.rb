class ReblogService < BaseService
  # Reblog a status and notify its remote author
  # @param [Account] account Account to reblog from
  # @param [Status] reblogged_status Status to be reblogged
  # @return [Status]
  def call(account, reblogged_status)
    reblog = account.statuses.create!(reblog: reblogged_status, text: '')
    DistributionWorker.perform_async(reblog.id)
    HubPingWorker.perform_async(account.id)

    if reblogged_status.local?
      NotificationMailer.reblog(reblogged_status, account).deliver_later unless reblogged_status.account.blocking?(account)
    else
      NotificationWorker.perform_async(reblog.stream_entry.id, reblogged_status.account_id)
    end

    reblog
  end

  private

  def send_interaction_service
    @send_interaction_service ||= SendInteractionService.new
  end
end
