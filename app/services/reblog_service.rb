class ReblogService < BaseService
  # Reblog a status and notify its remote author
  # @param [Account] account Account to reblog from
  # @param [Status] reblogged_status Status to be reblogged
  # @return [Status]
  def call(account, reblogged_status)
    reblog = account.statuses.create!(reblog: reblogged_status, text: '')
    return reblog if reblogged_status.local?
    send_interaction_service.(reblog.stream_entry, reblogged_status.account)
    reblog
  end

  private

  def send_interaction_service
    @send_interaction_service ||= SendInteractionService.new
  end
end
