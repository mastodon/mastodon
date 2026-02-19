# frozen_string_literal: true

class AnnualReport::TimeSeries < AnnualReport::Source
  def generate
    {
      time_series: [
        {
          month: 12,
          statuses: statuses_this_year,
          followers: followers_this_year,
        },
      ],
    }
  end

  private

  def statuses_this_year
    @statuses_this_year ||= report_statuses.count
  end

  def followers_this_year
    @followers_this_year ||= @account.passive_relationships.where(created_in_year, @year).count
  end

  def date_part_month
    Arel.sql(<<~SQL.squish)
      DATE_PART('month', created_at)::int
    SQL
  end

  def created_in_year
    Arel.sql(<<~SQL.squish)
      DATE_PART('year', created_at) = ?
    SQL
  end
end
