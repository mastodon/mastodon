# frozen_string_literal: true

class AnnualReport::TimeSeries < AnnualReport::Source
  MONTH_INDEXES = (1..12)

  def generate
    {
      time_series: time_series_map,
    }
  end

  private

  def time_series_map
    MONTH_INDEXES.map do |month|
      {
        month: month,
        statuses: statuses_per_month[month] || 0,
        following: following_per_month[month] || 0,
        followers: followers_per_month[month] || 0,
      }
    end
  end

  def statuses_per_month
    @statuses_per_month ||= monthly_statuses.to_h
  end

  def following_per_month
    @following_per_month ||= monthly_following.to_h
  end

  def followers_per_month
    @followers_per_month ||= monthly_followers.to_h
  end

  def monthly_statuses
    report_statuses
      .group(:period)
      .pluck(created_month.as('period'), Arel.star.count)
  end

  def monthly_following
    following_from_year
      .group(:period)
      .pluck(created_month.as('period'), Arel.star.count)
  end

  def monthly_followers
    followers_from_year
      .group(:period)
      .pluck(created_month.as('period'), Arel.star.count)
  end

  def following_from_year
    @account
      .active_relationships
      .where(created_year.eq(@year))
  end

  def followers_from_year
    @account
      .passive_relationships
      .where(created_year.eq(@year))
  end

  def created_year
    Arel.sql(<<~SQL.squish)
      DATE_PART('year', created_at)::int
    SQL
  end

  def created_month
    Arel.sql(<<~SQL.squish)
      DATE_PART('month', created_at)::int
    SQL
  end
end
