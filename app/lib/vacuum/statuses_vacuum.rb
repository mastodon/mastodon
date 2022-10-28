# frozen_string_literal: true

class Vacuum::StatusesVacuum
  include Redisable

  def initialize(retention_period)
    @retention_period = retention_period
  end

  def perform
    vacuum_statuses! if retention_period?
  end

  private

  def vacuum_statuses!
    statuses_scope.find_in_batches do |statuses|
      # Side-effects not covered by foreign keys, such
      # as the search index, must be handled first.

      remove_from_account_conversations(statuses)
      remove_from_search_index(statuses)

      # Foreign keys take care of most associated records
      # for us. Media attachments will be orphaned.

      Status.where(id: statuses.map(&:id)).delete_all
    end
  end

  def statuses_scope
    Status.unscoped.kept.where(account: Account.remote).where(Status.arel_table[:id].lt(retention_period_as_id)).select(:id, :visibility)
  end

  def retention_period_as_id
    Mastodon::Snowflake.id_at(@retention_period.ago, with_random: false)
  end

  def analyze_statuses!
    ActiveRecord::Base.connection.execute('ANALYZE statuses')
  end

  def remove_from_account_conversations(statuses)
    Status.where(id: statuses.select(&:direct_visibility?).map(&:id)).includes(:account, mentions: :account).each(&:unlink_from_conversations)
  end

  def remove_from_search_index(statuses)
    with_redis { |redis| redis.sadd('chewy:queue:StatusesIndex', statuses.map(&:id)) } if Chewy.enabled?
  end

  def retention_period?
    @retention_period.present?
  end
end
