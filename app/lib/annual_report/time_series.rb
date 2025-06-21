# frozen_string_literal: true

class AnnualReport::TimeSeries < AnnualReport::Source
  def generate
    {
      time_series: (1..12).map do |month|
                     {
                       month: month,
                       statuses: statuses_per_month[month] || 0,
                       following: following_per_month[month] || 0,
                       followers: followers_per_month[month] || 0,
                     }
                   end,
    }
  end

  private

  def statuses_per_month
    @statuses_per_month ||= report_statuses.group(:period).pluck(date_part_month.as('period'), Arel.star.count).to_h
  end

  def following_per_month
    @following_per_month ||= annual_relationships_by_month(@account.active_relationships)
  end

  def followers_per_month
    @followers_per_month ||= annual_relationships_by_month(@account.passive_relationships)
  end

  def date_part_month
    Arel.sql(<<~SQL.squish)
      DATE_PART('month', created_at)::int
    SQL
  end

  def annual_relationships_by_month(relationships)
    relationships
      .where(created_in_year, @year)
      .group(:period)
      .pluck(date_part_month.as('period'), Arel.star.count)
      .to_h
  end

  def created_in_year
    Arel.sql(<<~SQL.squish)
      DATE_PART('year', created_at) = ?
    SQL
  end
end
