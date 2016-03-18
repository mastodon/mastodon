class ReblogService < BaseService
  # Reblog a status and notify its remote author
  # @param [Account] account Account to reblog from
  # @param [Status] reblogged_status Status to be reblogged
  # @return [Status]
  def call(account, reblogged_status)
    reblog = account.statuses.create!(reblog: reblogged_status, text: '')
    fan_out_on_write_service.(reblog)
    account.ping!(account_url(account, format: 'atom'), [Rails.configuration.x.hub_url])
    return reblog if reblogged_status.local?
    send_interaction_service.(reblog.stream_entry, reblogged_status.account)
    reblog
  end

  private

  def send_interaction_service
    @send_interaction_service ||= SendInteractionService.new
  end

  def fan_out_on_write_service
    @fan_out_on_write_service ||= FanOutOnWriteService.new
  end
end
