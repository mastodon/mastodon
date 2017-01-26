# frozen_string_literal: true

class ReblogService < BaseService
  # Reblog a status and notify its remote author
  # @param [Account] account Account to reblog from
  # @param [Status] reblogged_status Status to be reblogged
  # @return [Status]
  def call(account, reblogged_status)
    reblogged_status = reblogged_status.reblog if reblogged_status.reblog?

    raise Mastodon::NotPermitted if reblogged_status.private_visibility? || !reblogged_status.permitted?(account)

    reblog = account.statuses.create!(reblog: reblogged_status, text: '')

    DistributionWorker.perform_async(reblog.id)
    Pubsubhubbub::DistributionWorker.perform_async(reblog.stream_entry.id)

    if reblogged_status.local?
      NotifyService.new.call(reblog.reblog.account, reblog)
    else
      NotificationWorker.perform_async(reblog.stream_entry.id, reblog.reblog.account_id)
    end

    reblog
  end

  private

  def send_interaction_service
    @send_interaction_service ||= SendInteractionService.new
  end
end
