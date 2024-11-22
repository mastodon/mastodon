# frozen_string_literal: true

class AnnualReport::Percentiles < AnnualReport::Source
  def self.prepare(year)
    AnnualReport::StatusesPerAccountCount.connection.exec_query(<<~SQL.squish, nil, [year, Mastodon::Snowflake.id_at(DateTime.new(year).beginning_of_year), Mastodon::Snowflake.id_at(DateTime.new(year).end_of_year)])
      INSERT INTO annual_report_statuses_per_account_counts (year, account_id, statuses_count)
      SELECT $1, account_id, count(*)
      FROM statuses
      WHERE id BETWEEN $2 AND $3
      AND (local OR uri IS NULL)
      GROUP BY account_id
      ON CONFLICT (year, account_id) DO NOTHING
    SQL
  end

  def generate
    {
      percentiles: {
        statuses: 100.0 - ((total_with_fewer_statuses / (total_with_any_statuses + 1.0)) * 100),
      },
    }
  end

  private

  def statuses_created
    @statuses_created ||= report_statuses.count
  end

  def total_with_fewer_statuses
    @total_with_fewer_statuses ||= AnnualReport::StatusesPerAccountCount.where(year: year).where(statuses_count: ...statuses_created).count
  end

  def total_with_any_statuses
    @total_with_any_statuses ||= AnnualReport::StatusesPerAccountCount.where(year: year).count
  end
end
