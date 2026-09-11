# frozen_string_literal: true

class ReblogService < BaseService
  include Authorization
  include Payloadable

  # Reblog a status and notify its remote author
  # @param [Account] account Account to reblog from
  # @param [Status] reblogged_status Status to be reblogged
  # @param [Hash] options
  # @option [String]  :visibility
  # @option [Boolean] :with_rate_limit
  # @return [Status]
  def call(account, reblogged_status, options = {})
    reblogged_status = reblogged_status.reblog if reblogged_status.reblog?

    authorize_with account, reblogged_status, :reblog?

    reblog = account.statuses.find_by(reblog: reblogged_status)

    return reblog unless reblog.nil?

    visibility = if reblogged_status.hidden?
                   reblogged_status.visibility
                 else
                   options[:visibility] || account.user&.setting_default_privacy
                 end

    reblog = account.statuses.create!(reblog: reblogged_status, text: '', visibility: visibility, rate_limit: options[:with_rate_limit])

    Trends.register!(reblog)
    DistributionWorker.perform_async(reblog.id)
    ActivityPub::DistributionWorker.perform_async(reblog.id)

    create_notification(reblog)
    increment_statistics

    reblog
  end

  private

  def create_notification(reblog)
    reblogged_status = reblog.reblog

    LocalNotificationWorker.perform_async(reblogged_status.account_id, reblog.id, reblog.class.name, 'reblog') if reblogged_status.account.local?
  end

  def increment_statistics
    ActivityTracker.increment('activity:interactions')
  end
end
