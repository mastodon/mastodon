# frozen_string_literal: true

class AnnualReport::Percentiles < AnnualReport::Source
  def generate
    {
      percentiles: {
        followers: (total_with_fewer_followers / (total_with_any_followers + 1.0)) * 100,
        statuses: (total_with_fewer_statuses / (total_with_any_statuses + 1.0)) * 100,
      },
    }
  end

  private

  def followers_gained
    @followers_gained ||= @account.passive_relationships.where("date_part('year', follows.created_at) = ?", @year).count
  end

  def statuses_created
    @statuses_created ||= @account.statuses.where(id: year_as_snowflake_range).count
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
    @total_with_any_followers ||= Follow.where("date_part('year', follows.created_at) = ?", @year).joins(:target_account).merge(Account.local).count('distinct follows.target_account_id')
  end

  def total_with_any_statuses
    @total_with_any_statuses ||= Status.where(id: year_as_snowflake_range).joins(:account).merge(Account.local).count('distinct statuses.account_id')
  end
end
