# frozen_string_literal: true

class DeletionScheduleWorker
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed, retry: 0

  def perform(account_id, delay)
    RemovalWorker.push_bulk(status_ids(account_id, snowflake_at(Time.now.utc - delay.seconds)))
  end

  private

  def snowflake_at(time)
    Mastodon::Snowflake.id_at(time)
  end

  def status_ids(account_id, cut_off_id)
    Status.where(account_id: account_id)
          .where(Status.arel_table[:id].lt(cut_off_id))
          .reorder(id: :asc)
          .limit(100)
          .pluck(:id)
  end
end
