# frozen_string_literal: true

class NotificationsCleanupService
  # This can be expensive, so instead of cleaning up everything
  # at once, we limit the number of accounts per run and run
  # this more often.
  ACCOUNTS_PER_RUN = 5

  # Unfiltered notifications do not need any additional
  # processing and can be deleted via SQL. This means we
  # can safely delete a large number in one run.
  UNFILTERED_DELETES_PER_ACCOUNT = 100_000

  # Filtered notifications need to update their associated
  # notification request. So we need to call #destroy on them
  # which means we can only delete a comparatively small number
  # in one run.
  FILTERED_DESTROYS_PER_ACCOUNT = 1_000

  # Different types of notifications may have different
  # policies of how much of them / how long to keep them around.
  POLICY_BY_TYPE = {
    default: {
      keep_at_least: 20_000,
      months_to_keep: 6,
    }.freeze,
  }.freeze

  def call(notification_type)
    @notification_type = notification_type

    accounts_with_old_notifications = fetch_accounts_with_old_notifications
    accounts_with_many_notifications = fetch_accounts_with_many_notifications
    affected_accounts = accounts_with_old_notifications & accounts_with_many_notifications

    affected_accounts.take(ACCOUNTS_PER_RUN).each do |account_id|
      base_query = construct_base_query(account_id)

      # Delete unfiltered notifications via SQL
      base_query
        .unfiltered
        .limit(UNFILTERED_DELETES_PER_ACCOUNT)
        .delete_all

      # Delete filtered notifications with '#destroy' to
      # update notification requests.
      base_query
        .filtered
        .limit(FILTERED_DESTROYS_PER_ACCOUNT)
        .destroy_all
    end
  end

  private

  def policy
    @policy ||= POLICY_BY_TYPE[@notification_type] || POLICY_BY_TYPE[:default]
  end

  def fetch_accounts_with_old_notifications
    Notification
      .where(type: @notification_type)
      .where(created_at: ...policy[:months_to_keep].months.ago)
      .distinct
      .pluck(:account_id)
  end

  def fetch_accounts_with_many_notifications
    Notification
      .from(
        Notification
          .select('account_id, COUNT(*) AS total')
          .where(type: @notification_type)
          .group(:account_id)
          .arel.as('totals')
      )
      .where('totals.total > ?', policy[:keep_at_least])
      .pluck(:account_id)
  end

  def find_min_created_at_to_keep(account_id)
    Notification
      .from(
        Notification
          .where(type: @notification_type)
          .where(account_id: account_id)
          .limit(policy[:keep_at_least])
          .order(created_at: :desc)
      )
      .group(:account_id)
      .minimum(:created_at)[account_id]
  end

  def construct_base_query(account_id)
    min_created_at_to_keep = find_min_created_at_to_keep(account_id)

    Notification
      .where(account_id: account_id)
      .where(type: @notification_type)
      .where(notifications: { created_at: ...min_created_at_to_keep })
      .where(notifications: { created_at: ...policy[:months_to_keep].months.ago })
  end
end
