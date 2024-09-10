# frozen_string_literal: true

class AnnualReport::Percentiles < AnnualReport::Source
  THRESHOLD_ADJUSTMENT = 1.0

  def generate
    {
      percentiles: {
        followers: followers_percentile,
        statuses: statuses_percentile,
      },
    }
  end

  private

  def followers_percentile
    (total_with_fewer_followers / adjusted_any_followers_count) * 100
  end

  def statuses_percentile
    (total_with_fewer_statuses / adjusted_any_statuses_count) * 100
  end

  def adjusted_any_followers_count
    total_with_any_followers + THRESHOLD_ADJUSTMENT
  end

  def adjusted_any_statuses_count
    total_with_any_statuses + THRESHOLD_ADJUSTMENT
  end

  def followers_gained
    @followers_gained ||= report_followers.count
  end

  def statuses_created
    @statuses_created ||= report_statuses.count
  end

  def total_with_fewer_followers
    @total_with_fewer_followers ||= Follow.find_by_sql([<<~SQL.squish, { year: @year, comparison: followers_gained }]).first.total
      WITH tmp0 AS (
        SELECT follows.target_account_id
        FROM follows
        INNER JOIN accounts ON accounts.id = follows.target_account_id
        WHERE date_part('year', follows.created_at) = :year
          AND accounts.domain IS NULL
        GROUP BY follows.target_account_id
        HAVING COUNT(*) < :comparison
      )
      SELECT count(*) AS total
      FROM tmp0
    SQL
  end

  def total_with_fewer_statuses
    @total_with_fewer_statuses ||= Status.find_by_sql([<<~SQL.squish, { comparison: statuses_created, min_id: year_as_snowflake_range.first, max_id: year_as_snowflake_range.last }]).first.total
      WITH tmp0 AS (
        SELECT statuses.account_id
        FROM statuses
        INNER JOIN accounts ON accounts.id = statuses.account_id
        WHERE statuses.id BETWEEN :min_id AND :max_id
          AND accounts.domain IS NULL
        GROUP BY statuses.account_id
        HAVING count(*) < :comparison
      )
      SELECT count(*) AS total
      FROM tmp0
    SQL
  end

  def total_with_any_followers
    @total_with_any_followers ||= local_account_targetting_follows.distinct.count(Follow.arel_table[:target_account_id])
  end

  def total_with_any_statuses
    @total_with_any_statuses ||= local_account_statuses.distinct.count(Status.arel_table[:account_id])
  end

  def local_account_targetting_follows
    Follow
      .where(follows_created_year.eq(@year))
      .joins(:target_account)
      .merge(Account.local)
  end

  def local_account_statuses
    Status
      .where(id: year_as_snowflake_range)
      .joins(:account)
      .merge(Account.local)
  end

  def report_followers
    @account
      .passive_relationships
      .where(follows_created_year.eq(@year))
  end

  def follows_created_year
    Arel.sql(<<~SQL.squish)
      DATE_PART('year', follows.created_at)::int
    SQL
  end
end
