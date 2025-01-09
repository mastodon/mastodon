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
    @statuses_per_month ||= report_statuses.group(:period).pluck(Arel.sql("date_part('month', created_at)::int AS period, count(*)")).to_h
  end

  def following_per_month
    @following_per_month ||= @account.active_relationships.where("date_part('year', created_at) = ?", @year).group(:period).pluck(Arel.sql("date_part('month', created_at)::int AS period, count(*)")).to_h
  end

  def followers_per_month
    @followers_per_month ||= @account.passive_relationships.where("date_part('year', created_at) = ?", @year).group(:period).pluck(Arel.sql("date_part('month', created_at)::int AS period, count(*)")).to_h
  end
end
